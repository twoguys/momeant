require "open-uri"

class User < ActiveRecord::Base
  
  devise :database_authenticatable, :registerable, #:confirmable,
    :recoverable, :rememberable, :trackable, :validatable
       
  searchable do
    text :name, :boost => 2.0
  end
  
  acts_as_taggable_on :interests
  
  geocoded_by :location
       
  PLEDGED_REWARD_REMINDER_THRESHOLD = 1.0
  PLEDGED_REWARD_STOP_THRESHOLD = 10.0
  PLEDGED_REWARD_CREDIT_LIMIT = 1.0

  has_many :created_stories, :foreign_key => :user_id, :class_name => "Story", :order => "created_at DESC"
  
  has_many :bookmarks, :dependent => :destroy
  has_many :bookmarked_stories, :through => :bookmarks, :source => :story
  
  has_many :rewards, :foreign_key => :recipient_id
  has_many :patrons, :through => :rewards, :source => :user, :uniq => true
  has_many :given_rewards, :class_name => "Reward", :dependent => :destroy, :order => "created_at DESC"
  has_many :rewarded_creators, :through => :given_rewards, :source => :recipient, :uniq => true
  has_many :rewarded_stories, :through => :given_rewards, :source => :story
  
  has_many :views, :dependent => :destroy
  has_many :viewed_stories, :through => :views, :source => :story

  has_many :subscriptions, :dependent => :destroy
  has_many :inverse_subscriptions, :class_name => "Subscription", :foreign_key => :subscriber_id, :dependent => :destroy
  has_many :followers, :through => :subscriptions, :source => :subscriber
  has_many :followings, :through => :inverse_subscriptions, :source => :user
  
  has_many :galleries, :order => :position, :dependent => :destroy
  
  has_many :amazon_payments, :foreign_key => :payer_id, :order => "created_at DESC"
  
  has_many :authentications
  
  has_many :sent_messages,
    :class_name => "Message",
    :foreign_key => "sender_id",
    :order => "created_at DESC",
    :conditions => ["sender_deleted = ?", false]
  has_many :received_messages,
    :class_name => "Message",
    :foreign_key => "recipient_id",
    :order => "created_at DESC",
    :conditions => ["recipient_deleted = ?", false]
  
  has_many :discussions, :order => "created_at DESC"
  
  has_one :editorial, :dependent => :destroy
  
  has_attached_file :avatar,
    :styles => { :thumbnail => "60x60#", :large => "200x200#", :editorial => "320x320#" },
    :path          => "avatars/:id/:style.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
  
  scope :most_rewarded, order("lifetime_rewards DESC")
  
  # VALIDATIONS
  
  validates :first_name, :presence => true, :length => (1...128)
  validates :last_name, :presence => true, :length => (1...128)
  validates :email, :presence => true, :format => /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i
  validates :tos_accepted, :presence => true, :inclusion => {:in => [true]} # :acceptance => true won't work...
  
  RECOMMENDATIONS_LIMIT = 10
  
  attr_accessor :invitation_code
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :tos_accepted,
    :avatar, :credits, :stored_in_braintree, :invitation_code, :tagline, :occupation, :amazon_email, :paypal_email, :interest_list,
    :location, :thankyou, :twitter_friends, :facebook_friends, :friends_last_cached_at, :latitude, :longitude,
    :send_reward_notification_emails, :send_digest_emails, :send_message_notification_emails, :amazon_status_code,
    :amazon_credit_instrument_id, :amazon_credit_sender_token_id, :amazon_settlement_token_id, :needs_to_reauthorize_amazon_postpaid
  
  def to_param
    "#{self.id}-#{self.name.gsub(/[^a-zA-Z]/,"-")}"
  end
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  def pay_email
    return "#{self.paypal_email} (PayPal)" if self.paypal_email.present?
    return "#{self.amazon_email} (Amazon)" if self.amazon_email.present?
    "none"
  end
  
  def geocode_if_location_provided
    return if self.location.blank?
    geocode and save
  end
  
  def geolocated?
    latitude.present? && longitude.present?
  end
  
  def discovery_content
    # TODO allow a creator to choose which piece of content (for now just pick newest)
    self.created_stories.published.newest_first.first
  end
  
  def media_count(type)
    self.created_stories.published.where(:media_type => type).count
  end
  
  def is_new?
    self.created_at > 2.weeks.ago
  end
  
  def is_featured?
    Editorial.all.map(&:user_id).include?(self.id)
  end
  
  def has_rewarded?(user)
    !Reward.where(:recipient_id => user.id, :user_id => self.id).empty?
  end
  
  def favorite_creators
    self.given_rewards.group_by(&:recipient).to_a.map {|x| [x.first,x.second.inject(0){|sum,r| sum+r.amount}]}.sort_by(&:second).reverse
  end
  
  def reward(story, amount, impacted_by = nil)
    return if amount.nil?
    return unless self.is_under_pledged_rewards_stop_threshold?
    
    old_badge_level = self.badge_level

    options = {:story_id => story.id, :amount => amount, :user_id => self.id, :recipient_id => story.user_id, :impact => amount}
    reward = Reward.create!(options)
    
    # handle people who previously purchased coins
    coin_amount = reward.amount / Reward.dollar_exchange
    if self.coins >= coin_amount
      reward.update_attribute(:paid_for, true)
      self.decrement!(:coins, coin_amount)
    
    # otherwise, use the normal Amazon Postpaid route
    elsif has_configured_postpaid?
      begin
        attribute_debt(reward.amount)
        settle_debt if surpassed_credit_limit?
      rescue Exception => e
        reward.destroy
        raise e
      end
      
    else
      # TODO: send an email to users who haven't configured Postpaid
    end
    
    story.increment!(:reward_count, amount)
    self.increment!(:impact, amount)
    reward.cache_impact!
    story.user.increment!(:lifetime_rewards, amount)
    
    Activity.create(:actor_id => self.id, :recipient_id => story.user_id, :action_type => "Reward", :action_id => reward.id)

    new_badge_level = self.reload.badge_level
    if new_badge_level != old_badge_level
      Activity.create(:actor_id => self.id, :action_type => "Badge", :action_id => new_badge_level)
    end
    
    if impacted_by
      parent_reward = Reward.find_by_id(impacted_by)
      reward.give_impact_to_parents!(parent_reward) if parent_reward
    end
    
    unless self.is_subscribed_to?(story.user)
      Subscription.create(:subscriber_id => self.id, :user_id => story.user_id)
    end
    
    return reward
  end
  
  def pledged_amount
    self.given_rewards.pledged.sum(:amount)
  end
  
  def is_under_pledged_rewards_reminder_threshold?
    self.pledged_amount < PLEDGED_REWARD_REMINDER_THRESHOLD
  end
  
  def is_under_pledged_rewards_stop_threshold?
    self.pledged_amount < PLEDGED_REWARD_STOP_THRESHOLD
  end
  
  def has_configured_postpaid?
    self.amazon_credit_instrument_id.present?
  end
  
  def surpassed_credit_limit?
    Rails.logger.info "PLEDGED AMOUNT: #{pledged_amount}"
    pledged_amount >= PLEDGED_REWARD_CREDIT_LIMIT
  end
  
  def attribute_debt(amount)
    amazon_payment = AmazonPayment.create(payer_id: self.id, amount: amount, used_for: "Pay", state: "initiated")
    amazon_payment.send_debt_to_amazon!
  end
  
  def settle_debt
    Rails.logger.info "PAYING FOR PLEDGED REWARDS"
    amazon_payment = AmazonPayment.create(payer_id: self.id, amount: pledged_amount, used_for: "SettleDebt", state: "initiated")
    success = amazon_payment.settle_postpaid_debt!
    Rails.logger.info "SETTLE DEBT SUCCESS? #{success}"
    self.given_rewards.pledged.update_all(paid_for: true, amazon_payment_id: amazon_payment.id) if success
  end
  
  def rewards_given_to(user)
    Reward.where(:user_id => self.id, :recipient_id => user.id).sum(:amount)
  end
  
  def amount_rewarded_for(content)
    reward = Reward.where(:user_id => self.id, :story_id => content.id).first
    return 0 if reward.nil?
    reward.amount
  end
  
  def impact_on(user)
    impact = ImpactCache.where(user_id: self.id, recipient_id: user.id).first
    impact.nil? ? 0.0 : impact.amount
  end
  
  def impact_from(user)
    impact = ImpactCache.where(recipient_id: self.id, user_id: user.id).first
    impact.nil? ? 0.0 : impact.amount
  end
  
  def can_comment_on?(object)
    if object.is_a?(Story)
      return true if self.has_rewarded?(object.user) || self == object.user
    end
    if object.is_a?(Discussion)
      return true if self.has_rewarded?(object.user) || self == object.user
    end
    return false
  end
  
  # Supporter Levels
  
  def top_supporters
    impacters = ImpactCache.order("amount DESC").where(recipient_id: self.id).includes(:user)
    impacters.map { |x| [x.user, x.amount] }
  end
  
  def gold_patrons
    self.top_supporters[0..2] || []
  end
  
  def silver_patrons
    self.top_supporters[3..5] || []
  end
  
  def bronze_patrons
    self.top_supporters[6..8] || []
  end
  
  def non_level_patrons
    self.top_supporters[9..-1] || []
  end
  
  def influenced
    my_reward_ids = self.given_rewards.map(&:id)
    return [] if my_reward_ids.empty?
    Reward.where("parent_id IN (#{my_reward_ids.join(',')})").map(&:user).uniq
  end
  
  def tags
    tags = self.given_rewards.map{|r| r.story.tags}.flatten
    tag_hash = Hash.new(0)
    tags.each do |tag|
      tag_hash[tag.name] += 1
    end
    tags.uniq.sort do |x,y|
      tag_hash[y.name] <=> tag_hash[x.name]
    end
  end
  
  def last_reward_for(story)
    Reward.where(:user_id => self.id, :story_id => story.id).first
  end
  
  def has_viewed?(story)
    View.where(:user_id => self.id, :story_id => story.id).present?
  end
  
  def has_viewed_this_period?(story)
    View.where(:user_id => self.id, :story_id => story.id).where("created_at > ?", self.subscription_last_updated_at).present?
  end
  
  # Badge calculation
  
  def badge_level
    return 0 if self.given_rewards.count == 0
    return 1 if self.amazon_payments.empty?
    return 2 if self.impact < 2
    return 3 if self.impact < 10
    return 4 if self.impact < 40
    return 5 if self.impact < 160
    return 6 if self.impact < 320
    return 7 if self.impact < 640
    return 8 if self.impact < 1280
    return 9
  end
  
  def badge_name(level = nil)
    level = badge_level if level.nil?
    
    case level
    when 1
      "Dilettante"
    when 2
      "Enthusiast"
    when 3
      "Afficionado"
    when 4
      "Buff"
    when 5
      "Big Buff"
    when 6
      "Petit Pundit"
    when 7
      "Artistic Epicure"
    when 8
      "Informal Angel"
    when 9
      "Cultural Connoisseur"
    end
  end
  
  def next_badge_level_name
    badge_name(badge_level + 1)
  end
  
  def rewards_until_next_badge
    return if badge_level < 2
    
    return 2 - impact if badge_level == 2
    return 10 - impact if badge_level == 3
    return 40 - impact if badge_level == 4
    return 160 - impact if badge_level == 5
    return 320 - impact if badge_level == 6
    return 640 - impact if badge_level == 7
    return 1280 - impact if badge_level == 8
  end
  
  # Sharing content with external services
  
  def post_to_facebook(object, url, comment = "")
    message = ""
    picture = ""
    
    if object.is_a?(Story)
      message = "I just posted content on Momeant. Reward me if you like it!"
      picture = object.thumbnail.url(:small)
    elsif object.is_a?(Reward)
      message = comment
      picture = object.story.thumbnail.url(:small)
    end
    
    access_token = self.authentications.find_by_provider("facebook").token
    RestClient.post 'https://graph.facebook.com/me/feed', { :access_token => access_token, :link => url, :picture => picture, :message => message }
    
    object.update_attribute(:shared_to_facebook, true) if object.is_a?(Reward)
  end
  
  def post_to_twitter(object, url, comment = "")
    auth = self.authentications.find_by_provider("twitter")
    Twitter.configure do |config|
      config.oauth_token = auth.token
      config.oauth_token_secret = auth.secret
    end
    
    message = ""
    if object.is_a?(Story)
      title = object.title[0..55]
      message = "I just posted some work on @momeant: #{url} #momeant"
    elsif object.is_a?(Reward)
      message = "#{comment[0..109]} #{url} #momeant"
    end
    
    Twitter.update(message, :wrap_links => true)
    
    object.update_attribute(:shared_to_twitter, true) if object.is_a?(Reward)
  end
  
  def cache_facebook_friends
    return if facebook_id.blank?
    
    access_token = self.authentications.find_by_provider("facebook").token
    data = RestClient.get "https://graph.facebook.com/me/friends?fields=id&access_token=#{access_token}"
    users = ActiveSupport::JSON.decode data

    facebook_ids = users["data"].map{ |friend| "'#{friend["id"]}'" }.join(",")
    return if facebook_ids.empty?
    momeant_ids = User.where("facebook_id IN (#{facebook_ids})").map(&:id).join(",")

    self.update_attributes(:facebook_friends => momeant_ids)
  end
  
  def cache_twitter_friends
    return if twitter_id.blank?
    
    data = RestClient.get "http://api.twitter.com/1/friends/ids.json?user_id=#{self.twitter_id}&cursor=-1"
    users = ActiveSupport::JSON.decode data
    
    twitter_ids = users["ids"].map{ |id| "'#{id}'" }.join(",")
    return if twitter_ids.empty?
    momeant_ids = User.where("twitter_id IN (#{twitter_ids})").map(&:id).join(",")
    
    self.update_attributes(:twitter_friends => momeant_ids)
  end
  
  def activity_from_twitter_and_facebook_friends
    # update friends list unless it was cached within the last day
    if friends_last_cached_at.nil? || friends_last_cached_at < 1.day.ago
      begin
        cache_facebook_friends
      rescue Exception
        Rails.logger.error "#{self.name} had an issue updating Facebook friends"
      end
      begin
        cache_twitter_friends
      rescue Exception
        Rails.logger.error "#{self.name} had an issue updating Twitter friends"
      end
      self.update_attribute :friends_last_cached_at, Time.now
    end
    
    friend_ids = []
    friend_ids += twitter_friends.split(',') unless twitter_friends.blank?
    friend_ids += facebook_friends.split(',') unless facebook_friends.blank?
    friend_ids.uniq!
    
    return [] if friend_ids.empty?
    Activity.
      where("actor_id IN (#{friend_ids.join(',')})").
      where("action_type = 'Reward' OR action_type = 'Story'")
  end
  
  def has_bookmarked?(story)
    Bookmark.where(:user_id => self.id, :story_id => story.id).present?
  end
  
  def has_recommended?(story)
    Recommendation.where(:user_id => self.id, :story_id => story.id).present?
  end
  
  def has_liked?(story)
    Like.where(:user_id => self.id, :story_id => story.id).present?
  end
  
  def is_subscribed_to?(user)
    self.followings.include?(user)
  end
  
  def nearby_content
    content = []

    user_ids = self.nearbys(30).map(&:id).join(",")
    unless user_ids.blank?
      content = Story.published.where("user_id IN (#{user_ids})").newest_first
    end
    
    # remove the ones I've already rewarded
    story_ids = self.given_rewards.map(&:story_id)
    unless story_ids.blank?
      content.reject!{|c| story_ids.include? c.id}
    end
    
    content
  end
  
  # Private Messages ---------------------------------------------------------------------------
  
  def messages
    Message.where("sender_id = ? or recipient_id = ?", self.id, self.id).where("parent_id IS NULL").order("created_at DESC")
  end
  
  def messages_from(user)
    Message.where("sender_id = ?", user.id).where("parent_id IS NULL").order("created_at DESC")
  end
  
  def unread_message_count
    count = 0
    self.messages.each do |message|
      count +=1 if message.unread_by(self.id)
    end
    count
  end
  
  # Recommendations ---------------------------------------------------------------------------
  
  def stories_tagged_similarly_to_what_ive_rewarded
    return [] if tags.empty? # my tags are based on the stories I've rewarded
    given_rewards_story_ids = given_rewards.map(&:story_id).join(",")
    stories = Story.
      where("stories.user_id != #{id}").
      where("stories.id NOT IN (#{given_rewards_story_ids})").
      tagged_with(tags.map(&:name), :any => true).
      joins(:curations).
      where("curations.user_id != #{id}").
      uniq
  end
  
  def rewarded_stories_from_people_i_subscribe_to
    stories = Story.where(:id => Reward.where(:user_id => self.subscribed_to).map{ |r| r.story_id })
    #rewarded_stories = self.rewarded_stories
    # remove stories I've created or rewarded
    stories.reject { |story| story.user == self } #|| rewarded_stories.include?(story) }
  end

  def rewards_from_people_i_subscribe_to
    rewards = Reward.where(:user_id => self.subscribed_to)
    #rewarded_story_ids = self.rewarded_stories.map {|story| story.id}
    my_created_story_ids = self.is_a?(Creator) ? self.created_stories.map {|story| story.id} : []
    ignore_story_ids = my_created_story_ids # + rewarded_story_ids
    # remove stories I've created or rewarded
    rewards.reject { |reward| ignore_story_ids.include?(reward.story_id) }
  end
  
  def stories_similar_to_my_bookmarks_and_rewards
    similar_stories = []
    self.bookmarks.each do |bookmark|
      similar_stories += bookmark.story.similar_stories
    end
    self.rewarded_stories.each do |rewarded_story|
      similar_stories += rewarded_story.similar_stories
    end
    # remove stories I've created or purchased or that are unpublished
    #purchased_stories = self.purchased_stories
    similar_stories.reject { |story| story.user == self || story.draft? }.uniq
  end
  
  def recommendation_stream
    (rewards_from_people_i_subscribe_to + stories_similar_to_my_bookmarks_and_rewards).sort do |x,y|
      x.created_at <=> y.created_at
    end
  end
  
  def avatar_missing?
    self.avatar.url.include?("missing")
  end
  
  def reload_avatar
    return false if avatar_missing?
    begin
      io = open(URI.parse(self.avatar.url))
      self.avatar = io
      self.save
    rescue Exception
    end
  end
  
  # Emails ---------------------------------------------------------------------------
  
  def self.send_activity_digests
    Creator.where(:send_digest_emails => true).each do |user|
      reward_count = user.rewards.in_the_past_two_weeks.sum(:amount)
      puts user.name if reward_count != 0
      impact_count = Activity.on_impact.involving(user).in_the_past_two_weeks.map(&:action).map(&:amount).inject(:+) || 0
      content_count = user.created_stories.in_the_past_two_weeks.count
      recommendations = user.stories_tagged_similarly_to_what_ive_rewarded[0..2]

      if reward_count != 0 || impact_count != 0 || content_count != 0
        DigestMailer.activity_digest(user, reward_count, impact_count, content_count, recommendations).deliver
      end
    end
  end
  
  def self.send_pledge_reminders
    Reward.pledged.includes(:user).group_by(&:user).each do |user_rewards|
      user = user_rewards[0]
      rewards = user_rewards[1]
      unless user.is_under_pledged_rewards_reminder_threshold?
        NotificationsMailer.pledged_reminder(user, rewards).deliver
      end
    end
  end
  
  # Reports -------------------------------------------------------------------------
  
  def self.per_day(time)
    by_day = self.where(created_at: (time.ago..Time.now)).group("date_trunc('day',created_at)").count
    (time.ago.to_date..Date.today).to_a.map do |date|
      by_day[date.beginning_of_day.to_s(:db)] || 0
    end
  end
  
end
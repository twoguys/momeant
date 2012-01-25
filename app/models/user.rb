require "open-uri"

class User < ActiveRecord::Base
  include AASM
  
  # Authentication configuration
  devise :database_authenticatable, :registerable, #:confirmable,
       :recoverable, :rememberable, :trackable, :validatable
       
  searchable do
    text :name, :boost => 2.0
    text :interests do
      interests.map { |interest| interest.name }
    end
  end
  
  acts_as_taggable_on :interests
  
  geocoded_by :location
       
  # ASSOCIATIONS
  
  has_many :purchases, :foreign_key => :payer_id
  has_many :purchased_stories, :through => :purchases, :source => :story
  has_many :stories, :through => :purchases, :foreign_key => :payer_id

  has_many :bookmarks, :dependent => :destroy
  has_many :bookmarked_stories, :through => :bookmarks, :source => :story
  
  has_many :given_rewards, :class_name => "Reward", :dependent => :destroy
  has_many :rewarded_creators, :through => :given_rewards, :source => :recipient, :uniq => true
  has_many :rewarded_stories, :through => :given_rewards, :source => :story
  
  has_many :views, :dependent => :destroy
  has_many :viewed_stories, :through => :views, :source => :story

  has_many :subscriptions, :dependent => :destroy
  has_many :inverse_subscriptions, :class_name => "Subscription", :foreign_key => :subscriber_id, :dependent => :destroy
  has_many :subscribers, :through => :subscriptions
  has_many :subscribed_to, :through => :inverse_subscriptions, :source => :user
  
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
  
  has_attached_file :avatar,
    :styles => { :thumbnail => "60x60#", :large => "200x200#" },
    :path          => "avatars/:id/:style.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
  
  scope :most_rewarded, order("lifetime_rewards DESC")
  
  # STATE MACHINE FOR PAID SUBSCRIPTIONS
  
  aasm_column :paid_state

  aasm_initial_state :trial

  aasm_state :trial
  aasm_state :trial_expired
  aasm_state :active_subscription, :enter => [:update_subscription_time, :update_trial_rewards, :update_trial_views]
  aasm_state :disabled_subscription
  
  aasm_event :expire_trial do
    transitions :to => :trial_expired, :from => :trial
  end

  aasm_event :start_paying do
    transitions :to => :active_subscription, :from => [:trial, :trial_expired]
  end

  aasm_event :stop_paying do
    transitions :to => :disabled_subscription, :from => :active_subscription
  end
  
  aasm_event :resume_paying do
    transitions :to => :active_subscription, :from => :disabled_subscription
  end
  
  # VALIDATIONS
  
  validates :first_name, :presence => true, :length => (1...128)
  validates :last_name, :presence => true, :length => (1...128)
  validates :email, :presence => true, :format => /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i
  validates :tos_accepted, :presence => true, :inclusion => {:in => [true]} # :acceptance => true won't work...
  
  validate  :extra_validations
  
  RECOMMENDATIONS_LIMIT = 10
  
  attr_accessor :invitation_code
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :tos_accepted,
    :avatar, :credits, :stored_in_braintree, :invitation_code, :tagline, :occupation, :paypal_email, :interest_list,
    :location, :thankyou, :twitter_friends, :facebook_friends, :friends_last_cached_at, :latitude, :longitude,
    :send_reward_notification_emails, :send_digest_emails, :send_message_notification_emails
  
  def extra_validations
    safe = true
    if ENV["CURRENT_RELEASE"] == 'private-beta'
      if self.new_record?
        # validate invitation code
        if self.invitation_code.blank?
          self.errors.add(:invitation_code, "is required during private beta.")
          safe = false
        elsif Invitation.find_by_token(self.invitation_code).nil?
          self.errors.add(:invitation_code, "is invalid. Please ensure you typed it correctly.")
          safe = false
        end
      end
    end
    return safe
  end
  
  def to_param
    "#{self.id}-#{self.name.gsub(/[^a-zA-Z]/,"-")}"
  end
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  def profile_complete?
    !self.avatar.url.include?("missing") &&
    self.occupation.present? &&
    self.tagline.present?
  end
  
  def can_view_stories?
    self.trial? || self.active_subscription?
  end
  
  def geocode_if_location_provided
    return if self.location.blank?
    geocode and save
  end
  
  def geolocated?
    latitude.present? && longitude.present?
  end
  
  def has_rewarded?(story)
    Reward.where(:user_id => self.id, :story_id => story.id).present?
  end
  
  def reward(story, amount, comment, impacted_by = nil)
    return if amount.nil?
    amount = amount.to_i
    if !can_afford?(amount)
      return false
    end
    
    options = {:story_id => story.id, :amount => amount, :user_id => self.id, :recipient_id => story.user_id, :comment => comment, :impact => amount}
    
    # track previous badge level to compare in a second
    old_badge_level = self.badge_level

    # create the reward and increment the necessary cache counters
    reward = Reward.create!(options)
    story.increment!(:reward_count, amount)
    self.decrement!(:coins, amount)
    self.increment!(:impact, amount)
    story.user.increment!(:lifetime_rewards, amount)
    
    # create the reward activity record
    Activity.create(:actor_id => self.id, :recipient_id => story.user_id, :action_type => "Reward", :action_id => reward.id)

    # if the user's badge level changed, record a badge activity record
    new_badge_level = self.reload.badge_level
    if new_badge_level != old_badge_level
      Activity.create(:actor_id => self.id, :action_type => "Badge", :action_id => new_badge_level)
    end
    
    # if this was impacted by another reward
    if impacted_by
      parent_reward = Reward.find_by_id(impacted_by)
      if parent_reward
        # make the new reward a child of the impacter reward
        reward.move_to_child_of(parent_reward)
        reward.update_attribute(:depth, reward.ancestors.count)

        # update all ancestor rewards' impact
        reward.ancestors.update_all("impact = impact + #{reward.amount}")
        
        # update all ancestors' user's impact, except for this reward's user (no double points!)
        ancestor_ids = reward.ancestors.map(&:user_id).uniq.reject{|user_id| user_id == reward.user_id}
        unless ancestor_ids.empty?
          User.where("id in (#{ancestor_ids.join(",")})").update_all("impact = impact + #{reward.amount}")
        end
        
        # record an activity for each ancestor getting impact
        reward.ancestors.map(&:user_id).uniq.each do |user_id|
          if user_id != reward.user_id
            Activity.create(:recipient_id => user_id, :action_type => "Impact", :action_id => reward.id)
          end
        end
      end
    end
    
    return reward
  end
  
  def following_stream(page = 1)
    subscribed_to = self.subscribed_to
    following_ids = subscribed_to.map { |user| user.id }

    # show my rewards too
    following_ids = following_ids.push(self.id).join(",")

    # removed -> select("DISTINCT ON (story_id) curations.*").
    Reward.where("story_id IS NOT NULL").where("user_id IN (#{following_ids})").page page
  end
  
  def rewards_given_to(user)
    Reward.where(:user_id => self.id, :recipient_id => user.id).sum(:amount)
  end
  
  def impact_on(user)
    Reward.where(:user_id => self.id, :recipient_id => user.id).map {|reward| reward.impact}.inject(:+) || 0
  end
  
  def influenced
    my_reward_ids = self.given_rewards.map(&:id)
    return [] if my_reward_ids.empty?
    Reward.where("parent_id IN (#{my_reward_ids.join(',')})").map(&:user).uniq
  end
  
  # def impact
  #   self.given_rewards.map {|reward| reward.impact}.inject(:+) || 0
  # end
  
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
  
  def can_afford?(amount)
    self.coins >= amount
  end
  
  def below_cashout_threshold?
    self.rewards.not_cashed_out.sum(:amount) < Reward.cashout_threshold
  end
  
  def needed_to_cashout
    Reward.cashout_threshold - self.rewards.not_cashed_out.sum(:amount)
  end
  
  def dollars
    self.rewards.not_cashed_out.sum(:amount) * Reward.dollar_exchange
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
    return 2 if self.impact < 20
    return 3 if self.impact < 100
    return 4 if self.impact < 400
    return 5 if self.impact < 1600
    return 6 if self.impact < 3200
    return 7 if self.impact < 6400
    return 8 if self.impact < 12800
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
    
    return 20 - impact if badge_level == 2
    return 100 - impact if badge_level == 3
    return 400 - impact if badge_level == 4
    return 1600 - impact if badge_level == 5
    return 3200 - impact if badge_level == 6
    return 6400 - impact if badge_level == 7
    return 12800 - impact if badge_level == 8
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
      message = "I just posted content on @mo_meant. Reward me if you like it: #{title} #{url} #momeant"
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
      cache_facebook_friends
      cache_twitter_friends
      self.update_attribute :friends_last_cached_at, Time.now
    end
    
    friend_ids = []
    friend_ids += twitter_friends.split(',') unless twitter_friends.blank?
    friend_ids += facebook_friends.split(',') unless facebook_friends.blank?
    friend_ids.uniq!
    
    return [] if friend_ids.empty?
    Activity.
      where("actor_id IN (#{friend_ids.join(',')})").
      where("action_type = 'Reward' OR action_type = 'Story'").
      limit(5)
  end
  
  
  def update_subscription_time
    self.update_attribute(:subscription_last_updated_at, Time.now)
  end
  
  def update_trial_rewards
    self.given_rewards.update_all(:given_during_trial => false)
  end

  def update_trial_views
    self.views.update_all(:given_during_trial => false, :created_at => Time.now)
  end
  
  def days_left_in_trial
    days_so_far = (Time.now - self.subscription_last_updated_at) / (60*60*24)
    30 - days_so_far.ceil
  end
  
  def spreedly_plan_url
    Spreedly.subscribe_url(self.id, ENV["SPREEDLY_PLAN_ID"], :email => self.email, :first_name => self.first_name, :last_name => self.last_name)
  end
  
  def refresh_from_spreedly
    Rails.logger.info "Getting info from Spreedly for #{self.name}"
    spreedly_user = Spreedly::Subscriber.find(self.id)
    Rails.logger.info spreedly_user.inspect
    if spreedly_user
      self.spreedly_token = spreedly_user.token
      self.spreedly_plan = spreedly_user.feature_level
      
      if spreedly_user.active
        self.start_paying! if self.trial? || self.trial_expired?
        self.resume_paying! if self.disabled_subscription?
      else
        self.stop_paying! if self.active_subscription?
      end
      
      self.save(:validate => false)
      Rails.logger.info "Spreedly info received, user is updated."
    else
      Rails.logger.info "Oops...no data received from Spreedly for #{self.name}."
    end
  end
  
  def purchase(story)
    return false unless can_afford?(story.price)
    
    momeant_portion = story.price * MOMEANT_STORY_SALE_FEE_PERCENTAGE
    creator_portion = story.price * (1 - MOMEANT_STORY_SALE_FEE_PERCENTAGE)
    
    purchase = Purchase.create(:amount => creator_portion, :story_id => story.id, :payer_id => self.id, :payee_id => story.user_id)
    unless story.free?
      self.decrement!(:credits, story.price)
      #story.user.increment!(:credits, creator_portion)
    end
    story.increment!(:purchased_count)

    return purchase
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
  
  def has_purchased?(story)
    self.stories.include?(story)
  end
  
  def recommendation_limit_reached?
    self.recommendations.count == RECOMMENDATIONS_LIMIT
  end
  
  def is_subscribed_to?(user)
    self.subscribed_to.include?(user)
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
    Message.where(:recipient_id => self.id).where("read_at IS NULL").count
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
  
  def reload_avatar
    return false if self.avatar.url.include?("missing")
    io = open(URI.parse(self.avatar.url))
    self.avatar = io
    self.save
  end
  
  # Emails ---------------------------------------------------------------------------
  
  def self.send_activity_digests
    Creator.where(:send_digest_emails => true).each do |user|
      reward_count = user.rewards.in_the_past_two_weeks.sum(:amount)
      impact_count = Activity.on_impact.involving(user).in_the_past_two_weeks.map(&:action).map(&:amount).inject(:+) || 0
      message_count = Message.where(:recipient_id => user.id).in_the_past_two_weeks.count
      content_count = user.created_stories.in_the_past_two_weeks.count
      recommendations = user.stories_tagged_similarly_to_what_ive_rewarded[0..2]

      if reward_count != 0 || impact_count != 0 || message_count != 0 || content_count != 0
        DigestMailer.activity_digest(user, reward_count, impact_count, message_count, content_count, recommendations).deliver
      end
    end
  end
end
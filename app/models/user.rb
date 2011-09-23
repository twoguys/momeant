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
       
  # ASSOCIATIONS
  
  has_many :purchases, :foreign_key => :payer_id
  has_many :purchased_stories, :through => :purchases, :source => :story
  has_many :stories, :through => :purchases, :foreign_key => :payer_id

  has_many :bookmarks
  has_many :bookmarked_stories, :through => :bookmarks, :source => :story
  
  has_many :given_rewards, :class_name => "Reward"
  has_many :rewarded_creators, :through => :given_rewards, :source => :recipient
  has_many :rewarded_stories, :through => :given_rewards, :source => :story
  
  has_many :views
  has_many :viewed_stories, :through => :views, :source => :story

  has_many :subscriptions
  has_many :inverse_subscriptions, :class_name => "Subscription", :foreign_key => :subscriber_id
  has_many :subscribers, :through => :subscriptions
  has_many :subscribed_to, :through => :inverse_subscriptions, :source => :user
  
  has_many :galleries
  
  has_many :amazon_payments, :foreign_key => :payer_id, :order => "created_at DESC"
  
  has_many :authentications
  
  has_attached_file :avatar,
    :styles => { :thumbnail => "60x60#" },
    :path          => "avatars/:id/:style.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
         
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
    :location
  
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
  
  def has_rewarded?(story)
    Reward.where(:user_id => self.id, :story_id => story.id).present?
  end
  
  def reward(story, amount, comment, impacted_by)
    return if amount.nil?
    amount = amount.to_i
    if can_afford?(amount)
      options = {:story_id => story.id, :amount => amount, :user_id => self.id, :recipient_id => story.user.id, :comment => comment}

      reward = Reward.create!(options)
      story.increment!(:reward_count, amount)
      self.decrement!(:coins, amount)
      story.user.increment!(:lifetime_rewards, amount)
      
      if impacted_by
        parent_reward = Reward.find_by_id(impacted_by)
        if parent_reward
          reward.move_to_child_of(parent_reward)
          reward.update_attribute(:depth, reward.ancestors.count)
        end
      end
      
      return reward
    end
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
  
  def impact
    self.given_rewards.map {|reward| reward.impact}.inject(:+) || 0
  end
  
  def last_reward_for(story)
    Reward.where(:user_id => self.id, :story_id => story.id).first
  end
  
  def can_afford?(amount)
    self.coins >= amount
  end
  
  def has_viewed?(story)
    View.where(:user_id => self.id, :story_id => story.id).present?
  end
  
  def has_viewed_this_period?(story)
    View.where(:user_id => self.id, :story_id => story.id).where("created_at > ?", self.subscription_last_updated_at).present?
  end
  
  
  # Sharing content with external services
  
  def post_to_facebook(object, url)
    message = ""
    
    if object.is_a?(Story)
      message = "I just posted content on Momeant. Reward me if you like it!"
    elsif object.is_a?(Reward)
      message = "I just rewarded something on Momeant. #{object.comment}"
    end
    
    access_token = self.authentications.find_by_provider("facebook").token
    RestClient.post 'https://graph.facebook.com/me/feed', { :access_token => access_token, :link => url, :message => message }
  end
  
  def post_to_twitter(object, url)
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
      title = object.story.title[0..65]
      message = "I just rewarded something on Momeant. Check it out: #{title} #{url} #momeant"
    end
    
    Twitter.update(message)
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
end
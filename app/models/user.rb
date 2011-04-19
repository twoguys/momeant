class User < ActiveRecord::Base
  include AASM
  
  # ASSOCIATIONS
  
  has_many :purchases, :foreign_key => :payer_id
  has_many :purchased_stories, :through => :purchases, :source => :story
  has_many :stories, :through => :purchases, :foreign_key => :payer_id

  has_many :bookmarks
  has_many :bookmarked_stories, :through => :bookmarks, :source => :story
  
  has_many :given_rewards, :class_name => "Reward", :foreign_key => :payer_id
  has_many :rewarded_creators, :through => :given_rewards, :source => :payee
  has_many :rewarded_stories, :through => :given_rewards, :source => :story
  has_many :rewards, :foreign_key => :payee_id
  has_many :patrons, :through => :rewards, :source => :payer

  has_many :subscriptions
  has_many :inverse_subscriptions, :class_name => "Subscription", :foreign_key => :subscriber_id
  has_many :subscribers, :through => :subscriptions
  has_many :subscribed_to, :through => :inverse_subscriptions, :source => :user
  
  has_many :credit_cards
  
  has_attached_file :avatar,
    :styles => { :thumbnail => "50x50#" },
    :path          => "avatars/:id/:style.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
  
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
         
  # STATE MACHINE FOR PAID SUBSCRIPTIONS
  
  aasm_column :paid_state

  aasm_initial_state :trial

  aasm_state :trial
  aasm_state :trial_expired
  aasm_state :active_subscription
  aasm_state :disabled_subscription
  
  aasm_event :expire_trial do
    transitions :to => :trial_expired, :from => [:trial]
  end

  aasm_event :start_paying do
    transitions :to => :active_subscription, :from => [:trial, :trial_expired, :disabled_subscription]
  end

  aasm_event :stop_paying do
    transitions :to => :disabled_subscription, :from => [:active_subscription]
  end
  
  # VALIDATIONS
  
  validates :first_name, :presence => true, :length => (1...128)
  validates :last_name, :presence => true, :length => (1...128)
  validates :email, :presence => true, :format => /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i
  
  validate  :extra_validations
  
  RECOMMENDATIONS_LIMIT = 10
  
  attr_accessor :invitation_code
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me,
    :avatar, :credits, :stored_in_braintree, :invitation_code, :tagline, :occupation
  
  def extra_validations
    safe = true
    if ENV["CURRENT_RELEASE"] == 'private-beta'
      if !self.confirmed?
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
  
  def can_view_stories?
    self.trial? || self.active_subscription?
  end
  
  def has_rewarded?(story)
    Reward.where(:payer_id => self.id, :story_id => story.id).present?
  end
  
  def reward(story, amount)
    return if amount.nil?
    amount = amount.to_i
    if can_afford?(amount)
      reward = Reward.create!(:amount => amount, :payer_id => self.id, :payee_id => story.user_id, :story_id => story.id)
      story.increment!(:reward_count, amount)
      self.decrement!(:coins, amount)
    end
  end
  
  def can_afford?(amount)
    self.coins >= amount
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
  
  def recommended_stories_from_people_i_subscribe_to
    stories = Story.where(:id => Recommendation.where(:user_id => self.subscribed_to).map{ |r| r.story_id })
    purchased_stories = self.purchased_stories
    # remove stories I've created or purchased
    stories.reject { |story| story.user == self || purchased_stories.include?(story) }
  end

  def recommendations_from_people_i_subscribe_to
    recommendations = Recommendation.where(:user_id => self.subscribed_to)
    purchased_story_ids = self.purchased_stories.map {|story| story.id}
    my_created_story_ids = self.is_a?(Creator) ? self.created_stories.map {|story| story.id} : []
    ignore_story_ids = purchased_story_ids + my_created_story_ids
    # remove stories I've created or purchased
    recommendations.reject { |recommendation| ignore_story_ids.include?(recommendation.story_id) }
  end
  
  def stories_similar_to_my_bookmarks_and_purchases
    similar_stories = []
    self.bookmarks.each do |bookmark|
      similar_stories += bookmark.story.similar_stories
    end
    self.stories.each do |purchased_story|
      similar_stories += purchased_story.similar_stories
    end
    # remove stories I've created or purchased or that are unpublished
    purchased_stories = self.purchased_stories
    similar_stories.reject { |story| story.user == self || purchased_stories.include?(story) || story.draft? }.uniq
  end
end
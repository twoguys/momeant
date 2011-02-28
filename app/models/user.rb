class User < ActiveRecord::Base
  has_many :purchases, :foreign_key => :payer_id
  has_many :purchased_stories, :through => :purchases, :source => :story

  has_many :stories, :through => :purchases, :foreign_key => :payer_id
  has_many :bookmarks
  has_many :bookmarked_stories, :through => :bookmarks, :source => :story
  has_many :recommendations
  has_many :recommended_stories, :through => :recommendations, :source => :story
  has_many :likes
  has_many :liked_stories, :through => :likes, :source => :story

  has_many :subscriptions
  has_many :inverse_subscriptions, :class_name => "Subscription", :foreign_key => :subscriber_id
  has_many :subscribers, :through => :subscriptions
  has_many :subscribed_to, :through => :inverse_subscriptions, :source => :user
  
  has_many :credit_cards
  
  validates :first_name, :presence => true, :length => (1...128)
  validates :last_name, :presence => true, :length => (1...128)
  validates :email, :presence => true, :format => /^([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})$/i
  
  RECOMMENDATIONS_LIMIT = 10
  
  has_attached_file :avatar,
    :styles => { :thumbnail => "50x50#" },
    :path          => "avatars/:id/:style.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :avatar, :credits, :stored_in_braintree
  
  def to_param
    "#{self.id}-#{self.name.gsub(/[^a-zA-Z]/,"-")}"
  end
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
  def can_afford?(amount)
    self.credits >= amount
  end
  
  def purchase(story)
    return false if !self.can_afford?(story.price)
    
    purchase = Purchase.create(:amount => story.price, :story_id => story.id, :payer_id => self.id, :payee_id => story.user_id)
    unless story.free?
      self.decrement!(:credits, story.price)
      story.user.increment!(:credits, story.price)
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
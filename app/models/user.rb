class User < ActiveRecord::Base
  has_many :purchases, :foreign_key => :payer_id

  has_many :stories, :through => :purchases, :foreign_key => :payer_id
  has_many :bookmarks
  has_many :bookmarked_stories, :through => :bookmarks, :source => :story
  has_many :recommendations
  has_many :recommended_stories, :through => :recommendations, :source => :story

  has_many :subscriptions
  has_many :inverse_subscriptions, :class_name => "Subscription", :foreign_key => :subscriber_id
  has_many :subscribers, :through => :subscriptions
  has_many :subscribed_to, :through => :inverse_subscriptions, :source => :user
  
  validates :name, :presence => true, :length => (3...128)
  
  RECOMMENDATIONS_LIMIT = 10
  
  has_attached_file :avatar,
    :styles => { :thumbnail => "80x80#" },
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
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :avatar
  
  def can_afford?(amount)
    self.money_available >= amount
  end
  
  def purchase(story)
    return false if !self.can_afford?(story.price)
    
    unless story.free?
      self.decrement!(:money_available, story.price)
      story.user.increment!(:credits, story.price)
    end
    story.increment!(:purchased_count)
    return Purchase.create(:amount => story.price, :story_id => story.id, :payer_id => self.id, :payee_id => story.user_id)
  end
  
  def has_bookmarked?(story)
    Bookmark.where(:user_id => self.id, :story_id => story).present?
  end
  
  def has_recommended?(story)
    Recommendation.where(:user_id => self.id, :story_id => story).present?
  end
  
  def recommendation_limit_reached?
    self.recommendations.count == RECOMMENDATIONS_LIMIT
  end
  
  def is_subscribed_to?(user)
    self.subscribed_to.include?(user)
  end
  
  def recommended_stories_from_people_i_subscribe_to
    Story.where(:id => Recommendation.where(:user_id => self.subscribed_to).map{ |r| r.story_id })
  end
end

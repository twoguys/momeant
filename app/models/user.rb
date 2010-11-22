class User < ActiveRecord::Base
  has_many :purchases, :foreign_key => :payer_id
  has_many :stories, :through => :purchases, :foreign_key => :payer_id
  
  validates_uniqueness_of :username
  
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
  attr_accessible :username, :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :avatar
  
  def name
    "#{self.first_name} #{self.last_name}"
  end
  
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
end

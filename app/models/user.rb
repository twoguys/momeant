class User < ActiveRecord::Base
  
  has_many :purchases
  has_many :stories, :through => :purchases
  
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
end

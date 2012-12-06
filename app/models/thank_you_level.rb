class ThankYouLevel < ActiveRecord::Base
  belongs_to :user
  has_many :achievements, class_name: "ThankYouAchievement"
  has_many :achievers, through: :achievements, source: :user
  
  validates :amount, numericality: true
  validates :item, presence: true
  
  default_scope order("amount ASC")
end
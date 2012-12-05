class ThankYouLevel < ActiveRecord::Base
  belongs_to :user
  has_many :achievements, class_name: "ThankYouAchievement"
  has_many :achievers, through: :achievements, source: :user
end
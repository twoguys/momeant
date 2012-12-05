class ThankYouAchievement < ActiveRecord::Base
  belongs_to :thank_you_level
  belongs_to :user
  belongs_to :creator
end
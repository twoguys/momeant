class ThankYouAchievement < ActiveRecord::Base
  belongs_to :thank_you_level
  belongs_to :user
  belongs_to :creator
  
  after_create :notify_creator
  
  def notify_creator
    NotificationsMailer.thank_you_level_achieved(self.creator, self.user, self.thank_you_level).deliver
  end
end
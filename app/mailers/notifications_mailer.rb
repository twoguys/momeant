class NotificationsMailer < ActionMailer::Base
  default :from => "Momeant <team@momeant.com>"
  
  def reward_notice(reward)
    @reward = reward
    
    mail :to => @reward.recipient.email, :subject => "You were just rewarded on Momeant!"
  end
end
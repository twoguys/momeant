class NotificationsMailer < ActionMailer::Base
  default :from => "Momeant <team@momeant.com>"
  layout "email"
  
  def reward_notice(reward)
    @reward = reward
    @messaging_url = user_messages_url(reward.user)
    
    mail :to => @reward.recipient.email, :subject => "You were just rewarded on Momeant!"
  end
end
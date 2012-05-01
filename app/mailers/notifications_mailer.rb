class NotificationsMailer < ActionMailer::Base
  default :from => "Momeant <team@momeant.com>"
  layout "email"
  
  def welcome_to_momeant(user)
    mail :to => user.email, :subject => "Welcome to Momeant!"
  end
  
  def reward_notice(reward)
    @reward = reward
    @messaging_url = user_messages_url(reward.user)
    
    mail :to => @reward.recipient.email, :subject => "You were just rewarded on Momeant!"
  end
  
  def message_notice(message)
    @message = message
    @messaging_url = user_messages_url(message.recipient)
    
    mail :to => @message.recipient.email, :subject => "#{message.sender.name} just messaged you on Momeant!"
  end
  
  def site_updated(user)
    mail :to => user.email, :subject => "Momeant has a new face!"
  end
  
  def pledged_reminder(user, rewards)
    @user = user
    @rewards = rewards
    @amount = @rewards.map(&:amount).inject(:+)
    mail :to => user.email, :subject => "Here's your chance to pay for your pledged rewards!"
  end
  
  def pledged_limit_reached(user, rewards)
    @user = user
    @rewards = rewards
    @amount = @rewards.map(&:amount).inject(:+)
    mail :to => user.email, :subject => "You've reached your pledged reward limit."
  end
end
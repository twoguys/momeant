class DigestMailer < ActionMailer::Base
  default :from => "Momeant <team@momeant.com>"
  layout "email"
  
  def activity_digest(user, reward_count, impact_count, message_count, content_count, recommendations)
    @user = user
    @reward_count = reward_count
    @impact_count = impact_count
    @message_count = message_count
    @content_count = content_count
    @recommendations = recommendations
    
    mail :to => @user.email, :subject => "Activity around you on Momeant"
  end
end

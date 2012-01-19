class DigestMailer < ActionMailer::Base
  default :from => "Momeant <team@momeant.com>"
  layout "email"
  
  def activity_digest(user)
    @user = user
    @reward_count = @user.rewards.in_the_past_two_weeks.sum(:amount)
    @impact_count = Activity.on_impact.involving(@user).in_the_past_two_weeks.map(&:action).map(&:amount).inject(:+) || 0
    @message_count = Message.where(:recipient_id => @user.id).in_the_past_two_weeks.count
    @content_count = @user.created_stories.in_the_past_two_weeks.count
    @recommendations = @user.stories_tagged_similarly_to_what_ive_rewarded[0..2]
    
    return if @reward_count == 0 && @impact_count == 0 && @message_count == 0 && @content_count == 0
    mail :to => @user.email, :subject => "Activity around you on Momeant", :from => "Momeant <team@momeant.com>"
  end
end

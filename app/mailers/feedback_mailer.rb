class FeedbackMailer < ActionMailer::Base
  default :from => "Momeant <noreply@momeant.com>"
  
  def give_feedback(comment, user)
    @comment = comment
    @user = user
    
    mail :to => "team@momeant.com", :subject => "User Feedback"
  end
end

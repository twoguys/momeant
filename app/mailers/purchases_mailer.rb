class PurchasesMailer < ActionMailer::Base
  default :from => "Momeant <noreply@momeant.com>"
  
  def purchase_receipt(user, story)
    @story = story
    @url = story_url(story)
    
    mail :to => user.email, :subject => "Thank you for your Momeant purchase!"
  end
end

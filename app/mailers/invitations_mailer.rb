class InvitationsMailer < ActionMailer::Base
  default :from => "noreply@momeant.com"
  
  def creator_invitation(invitation)
    @invitation = invitation
    @url = accept_invitation_url(invitation.token)
    
    mail :to => invitation.invitee_email, :subject => "You have been invited to be a Creator on Momeant"
  end
  
end

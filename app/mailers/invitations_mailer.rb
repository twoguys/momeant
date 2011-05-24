class InvitationsMailer < ActionMailer::Base
  default :from => "Momeant <noreply@momeant.com>"
  
  def creator_invitation(invitation)
    @invitation = invitation
    @url = accept_invitation_url(invitation.token)
    
    mail :to => invitation.invitee_email, :subject => "You have been invited to be a Creator on Momeant"
  end
  
  def creator_application(name, email, bio)
    @name = name
    @bio = bio
    @email = email
    
    mail :to => "create@momeant.com", :from => email, :subject => "Creator Application (#{name})"
  end
  
end
Factory.define :invitation do |invitation|
  invitation.inviter_id     { Factory(:creator).id }
  invitation.invited_as     "Creator"
  invitation.invitee_email  { "invitee@example.com" }
  invitation.accepted       false
end
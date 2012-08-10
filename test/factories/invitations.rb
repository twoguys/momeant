Factory.define :invitation do |invitation|
  invitation.inviter_id     { Factory(:creator).id }
end
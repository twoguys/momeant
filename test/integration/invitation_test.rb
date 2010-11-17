require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A creator or admin (user types) should be able to invite new creators" do

  in_order_to "have more content creators"
  as_a "creator or admin"
  i_want_to "be able to invite new people or existing users to be creators"
  
  Scenario "Inviting a non-existent user to be a creator by email" do
    Given "An email address does not exist in the system" do
      @invitee_email = "bob@example.com"
      assert User.where(:email => @invitee_email).empty?
    end
    
    Given "A creator exists" do
      @creator = Factory(:creator)
    end
    
    given_im_signed_in_as(:creator)
    
    when_i_visit_page(:invite_creator_invitations)
    
    And "I fill out and submit the form" do
      fill_in "invitation_invitee_email", :with => @invitee_email
      click_button "Invite Creator"
    end
    
    Then "An email should be sent to the invitee's address" do
      invite_email = ActionMailer::Base.deliveries.first
      assert_equal invite_email.subject, "You have been invited to be a Creator on Momeant"
      assert_equal invite_email.to[0], @invitee_email
    end
    
    And "An invitation should be created" do
      assert_not_nil Invitation.where(:invitee_email => @invitee_email, :inviter_id => @creator.id).first
    end
  end
  
  Scenario "Inviting an existing user to be a creator" do
    
  end
end
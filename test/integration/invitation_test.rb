require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A Creator or Admin should be able to invite new creators" do

  in_order_to "have more content creators"
  as_a "creator or admin"
  i_want_to "be able to invite new people to become creators"
  
  ["creator", "admin"].each do |user_type|
    Scenario "A #{user_type.capitalize} invites a non-existent user to be a creator by email" do
      Given "An email address does not exist in the system" do
        @invitee_email = "bob@example.com"
        assert User.where(:email => @invitee_email).empty?
      end
    
      Given "A #{user_type.capitalize} exists" do
        instance_variable_set("@#{user_type}", Factory(user_type.to_sym))
      end
    
      given_im_signed_in_as(user_type.to_sym)
    
      when_i_visit_page(:invite_creator_invitations)
    
      And "I fill out and submit the form" do
        fill_in "invitation_invitee_email", :with => @invitee_email
        click_button "Invite Creator"
      end
    
      Then "An email should be sent to the invitee's address" do
        invite_email = ActionMailer::Base.deliveries.last
        assert_equal invite_email.subject, "You have been invited to be a Creator on Momeant"
        assert_equal invite_email.to[0], @invitee_email
      end
    
      And "An invitation should be created" do
        inviter = instance_variable_get("@#{user_type}")
        assert_not_nil Invitation.where(:invitee_email => @invitee_email,:inviter_id => inviter.id).first
      end
    end
  end
  
  Scenario "Accepting an invite via the link in an email" do
    given_a(:invitation)
    
    When "I visit the invite link in my email" do
      visit accept_invitation_url(@invitation.token)
    end
    
    then_i_should_be_on_page(:new_user_registration)
    
    And "I fill out the form fields and submit the form" do
      fill_in "user_first_name", :with => "Creator"
      fill_in "user_last_name", :with => "Guy"
      fill_in "user_email", :with => "new_creator@example.com"
      fill_in "user_password", :with => "password"
      fill_in "user_password_confirmation", :with => "password"
      attach_file "user_avatar", File.join(Rails.root, "test/assets", "avatar.png")
      click_button "Sign up"
    end
    
    Then "The initee should now be a creator and the invite should be marked as accepted" do
      assert_not_nil Creator.where(:email => "new_creator@example.com").first
      assert Invitation.find(@invitation.id).accepted?
    end
  end
end
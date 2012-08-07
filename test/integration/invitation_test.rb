require 'test_helper'

Feature "An admin should be able to generate invitations" do

  in_order_to "give invitations to potential creators for them to signup"
  as_a "admin"
  i_want_to "be able to generate new invitations and see which have been used"

  Scenario "Viewing current invitations" do
    given_a :admin
    given_a :invitation
    given_im_signed_in_as :admin
    
    when_i_visit_page :admin_invitations
    
    Then "I should see information for the existing invitation" do
      assert page.has_content? Invitation.last.token
    end
  end
  
  Scenario "Creating a new invitation" do
    given_a :admin
    given_im_signed_in_as :admin
    
    when_i_visit_page :admin_invitations
    
    And "I click create new invitation" do
      click_button "Create new invitation"
    end
    
    Then "there should be a new invitation" do
      @invitation = Invitation.last
      assert_equal @admin, @invitation.inviter
    end
    
    And "I should be back on the invitations page" do
      assert_equal admin_invitations_path, current_path
    end
    
    And "I should see the recently-created invitation" do
      assert page.has_content? @invitation.token
    end
  end
  
end
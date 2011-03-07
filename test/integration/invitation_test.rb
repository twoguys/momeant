require 'test_helper'

Feature "An admin should be able to generate invitations to give out" do

  in_order_to "give invitations to users for them to hand out"
  as_a "admin"
  i_want_to "be able to generate new invitations and see which have been used"

  Scenario "Viewing current invitations" do
    given_a :admin
    Given "An invitation that's already been generated" do
      Factory :invitation, :inviter => @admin
    end
    given_im_signed_in_as :admin
    
    When "I visit my profile page and click on the invitations link" do
      visit user_path(@admin)
      click_link "Invitations"
    end
    
    then_i_should_be_on_page :admin_invitations
    
    And "I should see information for the existing invitation" do
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
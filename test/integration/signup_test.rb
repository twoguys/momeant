require 'test_helper'

Feature "A user should be able to sign up, sign in and sign out." do

  in_order_to "have an account"
  as_a "user"
  i_want_to "be able to sign up, sign in and sign out"
  
  Scenario "Filling out the signup form" do
    
    when_i_visit_page(:root)
    
    And "I click the Join link" do
      click_link "Sign Up"
    end
    
    And "I fill out the form fields and submit the form" do
      fill_in "user_first_name", with: "Adam"
      fill_in "user_last_name", with: "Adams"
      fill_in "user_email", with: "a@a.com"
      fill_in "user_password", with: "password"
      check "user_tos_accepted"
      click_button "sign up"
    end
    
    then_i_should_be_on_page(:root)
    
    And "a user should exist in the database" do
      assert User.where(email: "a@a.com").first.present?
    end
  end
  
  Scenario "Signing in" do
    given_a :user
    given_im_signed_in_as :user
    
    then_i_should_be_on_page :root
  end
  
  Scenario "Signing out" do
    given_a :user
    given_im_signed_in_as :user
    
    When "I click the signout link" do
      click_link "Log out"
    end
    
    Then "I should be logged out and see the join and login buttons" do
      assert find("#join").visible?
      assert find("#signin").visible?
    end
  end
  
  # Scenario "Signing up as a creator" do
  #   given_a :invitation
  #   
  #   when_i_visit_page(:creators)
  #   
  #   And "I fill out the form fields and submit the form" do
  #     fill_in "creator_invitation_code", with: @invitation.token
  #     fill_in "creator_email", with: "c@c.com"
  #     fill_in "creator_password", with: "password"
  #     check "creator_tos_accepted"
  #     click_button "Get Started"
  #   end
  #   
  #   Then "I should be on the creator info page" do
  #     user = User.last
  #     assert_equal creator_info_path(user), current_path
  #   end
  #   
  #   # Second step
  #   
  #   When "I fill in the creator info form" do
  #     attach_file "user_avatar", File.join(Rails.root, "test/assets", "avatar.png")
  #     fill_in "user_first_name", with: "John"
  #     fill_in "user_last_name", with: "Doe"
  #     fill_in "user_tagline", with: "Lorem ipsum dolor sit amet, consectetur adipisicing elit."
  #     fill_in "user_thankyou", with: "Lorem ipsum dolor sit amet, consectetur adipisicing elit."
  #     fill_in "user_occupation", with: "Builder"
  #     fill_in "user_location", with: "Brooklyn, NY"
  #     click_button "Final Step >"
  #   end
  #   
  #   Then "I should be on the creator payment page" do
  #     user = User.last
  #     assert_equal creator_payment_path(user), current_path
  #   end
  #   
  # end
  # 
  # Scenario "Logging in and upgrading to a creator" do
  #   given_a :invitation
  #   given_a :user
  #   
  #   when_i_visit_page(:creators)
  #   
  #   And "I fill out the form fields and submit the form" do
  #     fill_in "creator_invitation_code", with: @invitation.token
  #     fill_in "creator_email", with: @user.email
  #     fill_in "creator_password", with: "password"
  #     check "creator_tos_accepted"
  #     click_button "Get Started"
  #   end
  #   
  #   Then "I should be on the creator info page" do
  #     assert_equal creator_info_path(@user), current_path
  #   end
  # end
  
end
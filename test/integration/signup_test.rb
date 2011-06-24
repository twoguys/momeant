require 'test_helper'

Feature "A user should be able to sign up, sign in and sign out. Signing up immediately puts them in trial mode." do

  in_order_to "have an account"
  as_a "user"
  i_want_to "be able to sign up, sign in and sign out"

  Scenario "Visiting the homepage while not logged in and clicking the signup link" do
    when_i_visit_page(:home)
  
    Then "I can see the sign up and sign in links" do
      assert find("#signin").visible?
    end 

    When "I click the Join / Login link" do
      click_link "Join / Login"
    end

    Then "I should see a signup form" do
      assert page.find('input#user_first_name').visible?
      assert page.find('input#user_last_name').visible?
    end
  end
  
  Scenario "Filling out the signup form" do
    
    when_i_visit_page(:home)
    
    And "I click the Join / Login link" do
      click_link "Join / Login"
    end
    
    And "I fill out the form fields and submit the form" do
      fill_in "user_first_name", :with => "Adam"
      fill_in "user_last_name", :with => "Adams"
      fill_in "user_email", :with => "a@a.com"
      fill_in "user_password", :with => "password"
      #attach_file "user_avatar", File.join(Rails.root, "test/assets", "avatar.png")
      check "user_tos_accepted"
      click_button "sign up"
    end
    
    then_i_should_be_on_page(:home)
    
    #then_i_should_see_flash(:notice, "You have signed up successfully.")
    
    And "a user should exist in the database" do
      @user = User.where(:email => "a@a.com").first
      assert @user.present?
    end
    
    # And "they should have an avatar image" do
    #       assert_match /^http:\/\/s3.amazonaws.com/, @user.avatar.url
    #     end
    
    And "they should be in trial mode with 10 reward coins" do
      assert @user.trial?
      assert_equal 25, @user.coins
    end
  end
  
  # Scenario "Visiting the signup confirmation link" do
  #   given_a(:user)
  #   Given "The user has not confirmed their email" do
  #     @user.update_attribute(:confirmation_token, "fake_token")
  #   end
  #   
  #   When "I visit the confirmation link" do
  #     visit "/users/confirmation?confirmation_token=#{@user.confirmation_token}"
  #   end
  #   
  #   then_i_should_be_on_page :home
  #   
  #   And "I should see my name and a sign out link" do
  #     assert page.has_content? @user.name
  #     assert find_link("Sign out").visible?
  #   end
  # end
  
  Scenario "Signing in" do
    given_a(:email_confirmed_user)
    
    given_im_signed_in_as :email_confirmed_user
    
    then_i_should_be_on_page :home
  end
  
  Scenario "Signing out" do
    given_a(:email_confirmed_user)
    
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I click the signout link" do
      click_link "Sign out"
    end
    
    Then "I should be logged out and see the join/login button" do
      assert find("#signin").visible?
    end
  end
  
  Scenario "Expiring the trial period" do
    given_a(:email_confirmed_user)
    
    given_im_signed_in_as(:email_confirmed_user)
    
    Given "I signed up over 30 days ago and I'm still in trial" do
      @email_confirmed_user.update_attribute(:created_at, 31.days.ago)
    end
    
    When "I visit any page" do
      visit root_path
    end
    
    # turned off for now
    #
    # Then "my trial should be expired and I should be told so" do
    #       @email_confirmed_user.reload
    #       assert @email_confirmed_user.trial_expired?
    #       assert page.has_content? "Your trial has expired"
    #     end
  end
end
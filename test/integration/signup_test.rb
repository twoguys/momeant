require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able to sign up, sign in and sign out" do
  extend WebSteps

  in_order_to "have an account"
  as_a "user"
  i_want_to "be able to sign up, sign in and sign out"

  Scenario "Visiting the homepage while not logged in and clicking the signup link" do
    
    when_i_visit_page(:home)
    
    Then "I can see the sign up and sign in links" do
      assert find_link("Sign up").visible?
      assert find_link("Sign in").visible?
    end 

    When "I click the sign up link" do
      click_link "Sign up"
    end

    then_i_should_be_on_page(:new_user_registration)
    
    And "I should see a signup form" do
      assert page.has_selector?('input#user_email')
      assert page.has_selector?('input#user_password')
    end
  end
  
  Scenario "Filling out the signup form" do
    
    when_i_visit_page(:new_user_registration)
    
    And "I fill out the form fields and submit the form" do
      fill_in "user_email", :with => "a@a.com"
      fill_in "user_password", :with => "password"
      fill_in "user_password_confirmation", :with => "password"
      click_button "Sign up"
    end
    
    then_i_should_be_on_page(:new_user_session)
    
    then_i_should_see_flash(:notice, "You have signed up successfully.")
    
    And "A user should exist in the database" do
      assert_equal User.where(:email => "a@a.com").count, 1
    end
  end
  
  Scenario "Visiting the signup confirmation link" do
    
    Given "The user has not confirmed their email" do
      @user = Factory(:user)
      @user.update_attribute(:confirmation_token, "fake_token")
    end
    
    When "I visit the confirmation link" do
      visit "/users/confirmation?confirmation_token=#{@user.confirmation_token}"
    end
    
    then_i_should_be_on_page(:home)
    
    And "I should see my username and a sign out link" do
      assert page.has_content?(@user.username)
      assert find_link("Sign out").visible?
    end
  end
  
  Scenario "Signing in" do
    Given "An existing user" do
      @user = Factory(:email_confirmed_user)
    end
    
    when_i_visit_page(:new_user_session)
    
    And "I fill out and submit the form" do
      fill_in "user_email", :with => @user.email
      fill_in "user_password", :with => "password"
      click_button "Sign in"
    end
    
    then_i_should_be_on_page(:home)
    
    And "I should see my username and a sign out link" do
      assert page.has_content?(@user.username)
      assert find_link("Sign out").visible?
    end
  end
  
  Scenario "Signing out" do
    Given "A signed in user" do
      @user = Factory(:email_confirmed_user)
      visit new_user_session_path
      fill_in "user_email", :with => @user.email
      fill_in "user_password", :with => "password"
      click_button "Sign in"
    end
    
    When "I click the signout link" do
      click_link "Sign out"
    end
    
    Then "I should be logged out and see a sign in link" do
      assert page.has_content?("Sign in")
      assert page.has_content?("Sign up")
    end
  end
end
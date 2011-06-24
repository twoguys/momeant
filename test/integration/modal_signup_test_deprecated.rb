require 'test_helper'

Feature "A user should be able to sign up and sign in using the join button and modal", :testcase_class => FullStackTest do

  in_order_to "have an account"
  as_a "user"
  i_want_to "be able to sign up and sign in"

  Scenario "Visiting the homepage while not logged in, clicking the join button and signing up" do
    
    when_i_visit_page(:home)

    And "I click the join button" do
      click_link "join"
    end

    Then "I should see the join/login modal" do
      assert find("#join-login-modal").visible?
    end
    
    And "I should see a signup form" do
      assert page.has_selector?('input#user_email')
      assert page.has_selector?('input#user_password')
    end
    
    When "I fill out the form fields and submit the form" do
      fill_in "user_first_name", :with => "Adam"
      fill_in "user_last_name", :with => "Adams"
      fill_in "user_email", :with => "a@a.com"
      fill_in "user_password", :with => "password"
      fill_in "user_password_confirmation", :with => "password"
      attach_file "user_avatar", File.join(Rails.root, "test/assets", "avatar.png")
      click_button "sign up"
    end
    
    then_i_should_be_on_page(:new_user_session)
    
    then_i_should_see_flash(:notice, "You have signed up successfully.")
    
    And "A user should exist in the database" do
      assert_equal User.where(:email => "a@a.com").count, 1
    end
    
    And "The user should have an avatar image" do
      assert_match /^http:\/\/s3.amazonaws.com/, User.where(:email => "a@a.com").first.avatar.url
    end
  end
  
  Scenario "Visiting the homepage while not logged in, clicking the join/login button and logging in" do
    given_a(:email_confirmed_user)

    when_i_visit_page(:home)

    And "I click the join button" do
      click_link "join"
    end

    Then "I should see the join/login modal" do
      assert find("#join-login-modal").visible?
    end
    
    And "I should see a signup form" do
      assert page.has_selector?('input#login_email')
      assert page.has_selector?('input#login_password')
    end
    
    When "I fill out the form fields and submit the form" do
      fill_in "login_email", :with => @email_confirmed_user.email
      fill_in "login_password", :with => "password"
      click_button "login"
    end
    
    then_i_should_be_on_page :home
    
    And "I should see my name and a sign out link" do
      assert page.has_content? @email_confirmed_user.name
      assert find_link("Sign out").visible?
    end
  end
end
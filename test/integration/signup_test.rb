require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able to sign up, sign in and sign out" do
  extend WebSteps

  in_order_to "have an account"
  as_a "user"
  i_want_to "be able to sign up, sign in and sign out"

  Scenario "Visting the signup page while not logged in" do
    Given "I am not logged in" do
      # TODO: Devise Test helpers only work in controller tests...
    end
    
    when_i_visit_page(:home)
    
    Then "I can see the sign up and sign in links" do
      assert_contain "Sign up"
      assert_contain "Sign in"
    end 

    When "I click the sign up link" do
      click_link "Sign up"
    end

    then_i_should_be_on_page(:user_registration)
    
    Then "I should see a signup form" do
      within "form" do
        response.should have_selector('input#user_email')
      end
    end
  end
  
  Scenario "Visting the homepage when logged in"
end
require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able to see the home page" do
  extend WebSteps

  in_order_to "find out about Momeant"
  as_a "user"
  i_want_to "visit the homepage"

  Scenario "Visting the homepage when not logged in" do
    Given "I am not logged in" do
      # TODO: Devise Test helpers only work in controller tests...
    end 

    when_i_visit_page(:home)

    then_i_should_be_on_page(:home)
    
    Then "I should see a header with 'Momeant' in it" do
      assert_contain "Welcome to Momeant"
    end
    
    And "I should see an editorial section" do
      assert_have_selector "section#editorial"
    end
  end
  
  Scenario "Visting the homepage when logged in"
end
require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able to see the home page" do

  in_order_to "find out about Momeant"
  as_a "user"
  i_want_to "visit the homepage"

  Scenario "Visting the homepage when not logged in" do

    when_i_visit_page(:home)
    
    Then "I should see a header with 'Momeant' in it" do
      assert page.has_content? "Welcome to Momeant"
    end
    
    And "I should see an editorial section" do
      assert page.has_selector? "section#editorial"
    end
  end
  
  Scenario "Visting the homepage when logged in"
end
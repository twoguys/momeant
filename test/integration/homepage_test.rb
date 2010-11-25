require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able to see the home page" do

  in_order_to "find out about Momeant"
  as_a "user"
  i_want_to "visit the homepage"

  Scenario "Visting the homepage when not logged in" do
    Given "There are a few stories" do
      @user = Factory(:user)
      @user2 = Factory(:user)
      
      @story1 = Factory(:story)
      @story2 = Factory(:story)
    end

    when_i_visit_page(:home)
    
    Then "I should see a header with 'Momeant' in it" do
      assert page.has_content? "Welcome to Momeant"
    end
    
    And "I should see an editorial section" do
      assert page.has_selector? "section#editorial"
    end
    
    And "I should see a list of public stories (thumbnails)" do
      assert page.find('#recent-stories').has_content? @story1.title
      assert page.find('#recent-stories').has_content? @story2.title
    end
  end
  
  Scenario "Visting the homepage when logged in"
end
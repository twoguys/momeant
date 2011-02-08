require 'test_helper'

Feature "A user searches stories" do

  Scenario "A user searches for a story" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    Given "A story with the title 'Axel Rose'" do
      @story = Factory :story, :title => "Axel Rose"
    end
    
    when_i_visit_page(:home)
    
    And "I enter a search term and hit submit" do
      fill_in "query", :with => "Axel Rose"
      click_button "search-submit"
    end
    
    Then "I should see links to the story where the title matches" do
      assert page.has_content? @story.title
    end
    
  end
  
end
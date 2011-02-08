require 'test_helper'

Feature "A user searches stories" do

  Scenario "A user searches for a story" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    Given "A story with the title 'Axel Rose'" do
      Factory :story, :title => "Axel Rose"
    end
    
    when_i_visit_page(:home)
    
    And "I enter a search term and hit submit" do
      fill_in "query", :with => "Axel Rose"
      click_button "search-submit"
    end
    
    then_i_should_be_on_page(:search_stories)
    
    And "I should see links to the story where the title matches" do
      save_and_open_page
    end
    
  end
  
end
require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A Creator can create a story" do

  in_order_to "share my stories with others"
  as_a "creator or admin"
  i_want_to "create momeant stories"
  
  Scenario "A Creator creates a new story" do
    Given "A creator exists" do
      @creator = Factory(:creator)
      assert @creator.is_a?(Creator)
    end
    Given "A topic exists" do
      @topic = Factory(:topic)
    end
    
    given_im_signed_in_as(:creator)
    
    when_i_visit_page(:new_story)
    
    And "I fill out and submit the form" do
      fill_in "story_title", :with => "Little Red Riding Hood"
      fill_in "story_excerpt", :with => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor."
      check "topics_#{@topic.id}"
      fill_in "story_price", :with => "0.50"
      click_button "Create Story"
    end
    
    then_i_should_be_on_page(:preview_story) { Story.last }
    
    And "I should see my story information" do
      assert page.has_content? "Little Red Riding Hood"
      assert page.has_content? "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor."
      assert page.has_content? @topic.name
      assert @creator.stories.include?(Story.last)
    end
  end
  
end
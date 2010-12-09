require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A Creator can create a story" do

  in_order_to "share my stories with others"
  as_a "creator or admin"
  i_want_to "create momeant stories"
  
  Scenario "A Creator creates a new story" do
    setup { Capybara.current_driver = :envjs }
    
    given_a :creator
    given_a :topic
    
    given_im_signed_in_as :creator
    
    when_i_visit_page :new_story
        
    And "I fill out the story title, excerpt, topics and price" do
      fill_in "story_title", :with => "Little Red Riding Hood"
      fill_in "story_excerpt", :with => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor."
      check "topics_#{@topic.id}"
      fill_in "story_price", :with => "0.50"
    end
    
    And "I click the page editor link" do
      click_link "Open Page Editor"
    end
    
    Then "I should be in the fullscreen page editor" do
      assert page.find("#page-editor").has_content? "hello world"
    end
    
    # then_i_should_be_on_page(:preview_story) { Story.last }
    #     
    #     And "I should see my story information" do
    #       assert page.has_content? "Little Red Riding Hood"
    #       assert page.has_content? "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor."
    #       assert page.has_content? @topic.name
    #       assert @creator.created_stories.include?(Story.last)
    #     end
  end
  
  # Scenario "A regular user (non-Creator) tries to access the new story page" do
  #   #setup { Capybara.current_driver = :rack_test }
  #   
  #   given_a(:email_confirmed_user)
  #   
  #   given_im_signed_in_as(:email_confirmed_user)
  #   
  #   when_i_visit_page(:new_story)
  #   
  #   then_i_should_be_on_page(:home)
  #   
  #   then_i_should_see_flash(:alert, "You are not authorized to access this page.")
  # end
  
end
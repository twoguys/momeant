require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A Creator can create a story", :testcase_class => FullStackTest do
  extend StoryCreationSteps
  
  in_order_to "share my stories with others"
  as_a "creator or admin"
  i_want_to "create momeant stories"
  
  setup { Capybara.current_driver = :selenium }
  teardown { Capybara.use_default_driver }
    
  Scenario "A Creator creates a new story" do
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
    
    and_i_open_the_page_editor
    
    and_i_choose_the_title_theme_and_fill_in_a_title_for_page(1)
    
    and_i_goto_the_next_page
    
    and_i_choose_the_image_theme_and_choose_an_image_for_page(2)
    
    and_i_goto_the_next_page
    
    and_i_choose_the_pullquote_theme_and_fill_in_a_quote_for_page(3)
    
    and_i_close_the_page_editor
    
    And "I click Create Story" do
      click_button "Create Story"
    end
    
    then_i_should_be_on_page(:preview_story) { Story.last }
        
    And "I should see my story information" do
      assert page.has_content? "Little Red Riding Hood"
      assert page.has_content? "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor."
      assert page.has_content? @topic.name
      assert @creator.created_stories.include?(Story.last)
    end
  end
  
  # Scenario "A regular user (non-Creator) tries to access the new story page" do
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
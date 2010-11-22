require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user can acquire a story" do

  in_order_to "get access to Momeant stories"
  as_a "user"
  i_want_to "acquire/purchase a story"
  
  Scenario "A user acquires a free story" do
    Given "An existing user and free story" do
      @user = Factory(:email_confirmed_user)
      @story = Factory(:free_story)
    end
    
    given_im_signed_in_as(:user)
    
    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    Then "I should see that the story is free to acquire" do
      assert page.find('.price').has_content? "free"
      assert page.find('.price').find('a.buy-it').has_content? "acquire"
    end
    
    When "I click the acquire link" do
      click_link("acquire")
    end
    
    Then "I should be on the story view page" do
      assert_equal story_path(@story), current_path
    end
    
    then_i_should_see_flash(:notice, "This story is now in your library.")
    
    And "I should see the story content" do
      assert page.has_content? @story.title
      assert page.has_content? @story.excerpt
    end
    
    when_i_visit_page(:library)
    
    then_i_should_be_on_page(:library)
    
    Then "I should see a link to the story I just acquired" do
      assert find_link(@story.title).visible?
    end
  end
  
end
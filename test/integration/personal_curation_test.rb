require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user wants to personally curate their experience" do

  in_order_to "keep track of content I like"
  as_a "user"
  i_want_to "be able to bookmark stories and see the list later"
  
  Scenario "A user bookmarks a story they like" do
    given_a(:email_confirmed_user)
    given_a(:story)
    
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    And "I click the bookmark button" do
      click_button("bookmark story")
    end
    
    Then "I should be on the story preview page" do
      assert_equal preview_story_path(@story), current_path
    end
    
    then_i_should_see_flash(:notice, "Story bookmarked.")
    
    And "the story should show up in my bookmarked stories" do
      assert @email_confirmed_user.bookmarked_stories.include?(@story)
    end
    
    And "the user should show up in the story's users who bookmarked" do
      assert @story.users_who_bookmarked.include?(@email_confirmed_user)
    end
    
    when_i_visit_page(:bookmarked_stories)
    
    then_i_should_be_on_page(:bookmarked_stories)
    
    And "I should see a link to my bookmarked story" do
      assert page.find_link(@story.title).visible?
    end
  end
  
  Scenario "A user unbookmarks a story they previously bookmarked" do
    given_a(:email_confirmed_user)
    given_a(:story)
    Given "An existing bookmark" do
      Bookmark.create(:user_id => @email_confirmed_user.id, :story_id => @story.id)
    end
    
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    And "I click the unbookmark button" do
      click_button("unbookmark story")
    end
    
    Then "I should be on the story preview page" do
      assert_equal preview_story_path(@story), current_path
    end
    
    then_i_should_see_flash(:notice, "Bookmark removed.")
    
    And "the story should no longer be in my bookmarked stories" do
      assert !@email_confirmed_user.bookmarked_stories.include?(@story)
    end
    
    And "the user should not be in the story's users who bookmarked" do
      assert !@story.users_who_bookmarked.include?(@email_confirmed_user)
    end
  end
end
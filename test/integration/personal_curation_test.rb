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
  
  Scenario "A user sees recommended stories on their homepage that match their personally curated stories" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    Given "A few bookmarked stories for the user" do
      @bookmark = Factory(:bookmark, :user => @email_confirmed_user)
      @bookmark2 = Factory(:bookmark, :user => @email_confirmed_user)
    end
    Given "Two stories whose topics match one of the bookmarked stories" do
      @topic_matching_story = Factory(:story, :topics => [@bookmark.story.topics.first])
      @topic_matching_story2 = Factory(:story, :topics => [@bookmark.story.topics.second])
    end
    Given "Another two stories by the same creator as one of the bookmarked stories" do
      @creator_matching_story = Factory(:story, :user => @bookmark2.story.user)
      @creator_matching_story2 = Factory(:story, :user => @bookmark2.story.user)
    end
    Given "Two stories that I purchased" do
      @purchase = Factory(:purchase, :payer => @email_confirmed_user)
      @purchase2 = Factory(:purchase, :payer => @email_confirmed_user)
    end
    Given "Two stories whose topics match one of the purchased stories" do
      @topic_matching_purchased_story = Factory(:story, :topics => [@purchase.story.topics.first])
      @topic_matching_purchased_story2 = Factory(:story, :topics => [@purchase.story.topics.second])
    end
    Given "Another two stories by the same creator as one of the purchased stories" do
      @creator_matching_purchased_story = Factory(:story, :user => @purchase2.story.user)
      @creator_matching_purchased_story2 = Factory(:story, :user => @purchase2.story.user)
    end
    Given "A story that doesn't match either topics or creator" do
      @unmatching_story = Factory(:story)
    end
    
    when_i_visit_page(:home)
    
    Then "I should see the topic-matching stories in my list of recommended stories" do
      assert page.find('#similar-to-bookmarked-stories').has_content? @topic_matching_story.title
      assert page.find('#similar-to-bookmarked-stories').has_content? @topic_matching_story2.title
    end
    
    And "I should see the creator-matching stories in my list of recommended stories" do
      assert page.find('#similar-to-bookmarked-stories').has_content? @creator_matching_story.title
      assert page.find('#similar-to-bookmarked-stories').has_content? @creator_matching_story2.title
    end
    
    And "I should see the topic-matching purchased stories in my list of recommended stories" do
      assert page.find('#similar-to-bookmarked-stories').has_content? @topic_matching_purchased_story.title
      assert page.find('#similar-to-bookmarked-stories').has_content? @topic_matching_purchased_story2.title
    end
    
    And "I should see the creator-matching purchased stories in my list of recommended stories" do
      assert page.find('#similar-to-bookmarked-stories').has_content? @creator_matching_purchased_story.title
      assert page.find('#similar-to-bookmarked-stories').has_content? @creator_matching_purchased_story2.title
    end
    
    And "I should NOT see the unmatching story" do
      assert !page.find('#similar-to-bookmarked-stories').has_content?(@unmatching_story.title)
    end
  end
end
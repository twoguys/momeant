require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user wants to publicly curate for others" do

  in_order_to "share the content I like with others"
  as_a "user"
  i_want_to "be able to recommend stories and see the list later"
  
  Scenario "A user recommends a story they like" do
    given_a(:email_confirmed_user)
    given_a(:story)
    
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    And "I click the recommend button" do
      click_button("recommend story")
    end
    
    Then "I should be on the story preview page" do
      assert_equal preview_story_path(@story), current_path
    end
    
    then_i_should_see_flash(:notice, "Story recommended.")
    
    And "the story should be in my recommended stories" do
      assert @email_confirmed_user.recommended_stories.include?(@story)
    end
    
    And "the user should be in the story's users who recommended" do
      assert @story.users_who_recommended.include?(@email_confirmed_user)
    end
    
    when_i_visit_page(:recommended_stories)
    
    then_i_should_be_on_page(:recommended_stories)
    
    And "I should see a link to my recommended story" do
      assert page.find_link(@story.title).visible?
    end
  end
  
  Scenario "A user unrecommends a story they previously recommended" do
    given_a(:email_confirmed_user)
    given_a(:story)
    Given "A recommendation already exists for this story/user" do
      Recommendation.create(:story_id => @story.id, :user_id => @email_confirmed_user.id)
    end
    
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    And "I click the unrecommend button" do
      click_button("unrecommend story")
    end
    
    Then "I should be on the story preview page" do
      assert_equal preview_story_path(@story), current_path
    end
    
    then_i_should_see_flash(:notice, "Recommendation removed.")
    
    And "the story should not be in my recommended stories" do
      assert !@email_confirmed_user.recommended_stories.include?(@story)
    end
    
    And "the user should not be in the story's users who recommended" do
      assert !@story.users_who_recommended.include?(@email_confirmed_user)
    end
  end
  
end
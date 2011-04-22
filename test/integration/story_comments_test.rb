require 'test_helper'
include ActionView::Helpers::TextHelper

Feature "A user should be able to comment on a story", :testcase_class => FullStackTest do

  in_order_to "have a discussion with the creator and community around a story"
  as_a "user"
  i_want_to "be able to comment on a story"

  Scenario "Commenting on a story from the preview page" do
    given_a(:email_confirmed_user)
    given_a(:story)
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I visit the story's preview path" do
      visit preview_story_path(@story)
      @old_comment_count = @story.comment_count
    end
    
    And "I type a comment and hit post" do
      fill_in "curation_comment", :with => "Here is a sweet comment about your awesome story!"
      click_button "Post"
    end
    
    Then "there should be a new comment assigned to the story" do
      assert_equal "Here is a sweet comment about your awesome story!", @story.comments.last.comment
    end
    
    And "the story's comment count should be one higher" do
      @story.reload
      assert_equal @old_comment_count + 1, @story.comment_count
    end
    
    And "I should be back on the preview page and see the new total comments and my comment" do
      assert_equal preview_story_path(@story), current_path
      assert page.has_content? pluralize(@story.comment_count, "comments")
      assert page.has_content? "Here is a sweet comment about your awesome story!"
    end
  end
end
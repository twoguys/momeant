require 'test_helper'
include ActionView::Helpers::TextHelper

Feature "A story's view count should go up if a user views a story" do

  in_order_to "to see analytics on my content"
  as_a "creator"
  i_want_to "be able to see view counts"

  Scenario "Someone views a story" do
    given_a(:story)
    
    When "I view a story" do
      @old_view_count = @story.view_count
      visit story_path(@story)
    end
    
    Then "the story's view_count should be 1 higher" do
      @story.reload
      assert_equal @old_view_count + 1, @story.view_count
    end
  end
  
end
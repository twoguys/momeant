require 'test_helper'
include ActionView::Helpers::TextHelper

Feature "A view record should be recorded (max of once per subscription period) if a user views a story" do

  in_order_to "pay creators whose stories are being viewed"
  as_a "system"
  i_want_to "be able to record unique user views"

  Scenario "A user views a story for the first time in this subscription period" do
    given_a(:email_confirmed_user)
    given_a(:story)
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I view a story" do
      @old_view_count = @story.view_count
      visit story_path(@story)
    end
    
    Then "there should be a View recorded for this user and story" do
      assert View.where(:story_id => @story.id, :user_id => @email_confirmed_user.id).present?
    end
    
    And "the story's view_count should be 1 higher" do
      @story.reload
      assert_equal @old_view_count + 1, @story.view_count
    end
    
    When "the user views the story again soon after (in the same subscription period)" do
      visit story_path(@story)
    end
    
    Then "there should not be another view" do
      assert_equal 1, View.where(:story_id => @story.id, :user_id => @email_confirmed_user.id).count
    end
    
    When "time progresses and your subscription period moves into the next one" do
      @email_confirmed_user.update_attribute(:subscription_last_updated_at, Time.now)
    end
    
    And "I view the story again" do
      visit story_path(@story)
    end
    
    Then "there should be a second View recorded for this user and story" do
      assert_equal 2, View.where(:story_id => @story.id, :user_id => @email_confirmed_user.id).count
    end
  end
end
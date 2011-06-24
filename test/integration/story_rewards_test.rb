require 'test_helper'
include ActionView::Helpers::TextHelper

Feature "A user should be able to reward a creator for a story" do

  in_order_to "show my support and appreciation for a story"
  as_a "user"
  i_want_to "be able to reward the creator"

  Scenario "Rewarding a story from the preview page" do
    given_a(:user_with_coins)
    given_a(:story)
    given_im_signed_in_as(:user_with_coins)
    
    When "I visit the story's preview path" do
      visit preview_story_path(@story)
      @old_reward_count = @story.reward_count
    end
    
    And "I click the reward button" do
      click_link pluralize(@story.rewards.count, "reward coin")
    end
    
    And "I choose the 1-coin reward" do
      choose "reward_amount_2"
      click_button "Give Reward"
    end
    
    Then "there should be a new reward assigned to the story and linking to me and the creator" do
      @reward = Reward.last
      assert_equal @user_with_coins, @reward.user
      assert_equal @story.user, @reward.recipient
      assert_equal @story, @reward.story
      assert_equal 2, @reward.amount
    end
    
    And "the story's reward count should be one higher" do
      @story.reload
      assert_equal @old_reward_count + 2, @story.reward_count
    end
    
    # And "I should be back on the preview page and see the new total rewards" do
    #   assert_equal preview_story_path(@story), current_path
    #   assert page.has_content? pluralize(@story.reward_count, "reward coin")
    # end
  end
  
  Scenario "Rewarding a story during trial and later paying for a Momeant subscription" do
    given_a(:trial_user)
    given_a(:story)
    given_im_signed_in_as(:trial_user)
    
    When "I reward a story" do
      visit preview_story_path(@story)
      click_link pluralize(@story.rewards.count, "reward coin")
      choose "reward_amount_2"
      click_button "Give Reward"
    end
    
    Then "the reward should be marked as given by a trial user" do
      @reward = Reward.last
      assert @reward.given_during_trial?
    end
    
    When "the user who rewarded later starts paying for a subscription" do
      @trial_user.start_paying!
    end
    
    Then "the reward should be unmarked as given by a trial user" do
      @reward.reload
      assert !@reward.given_during_trial?
      assert @trial_user.given_rewards.given_during_trial.empty?
    end
  end
end
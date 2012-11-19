require 'test_helper'
include ActionView::Helpers::TextHelper

Feature "A user should be able to reward a creator for a story" do

  in_order_to "show my support and appreciation for a story"
  as_a "user"
  i_want_to "be able to reward the creator"

  Scenario "Rewarding a story in the presenter" do
    given_a(:user)
    given_a(:story)
    given_im_signed_in_as(:user)
    
    When "I view the story" do
      visit story_path(@story)
      @old_reward_count = @story.reward_count.to_i
    end
    
    And "I open up the reward sidebar" do
      click_link("reward-button")
    end
    
    And "I choose the one dollar reward and submit" do
      # Since the reward modal loads in a lightbox iframe and I want to avoid having to
      # make this a Selenium test (eww), I'm just visiting the reward modal path directly
      visit reward_story_path(@story)
      page.find("#one-dollar-reward").click
      click_button "Give Reward"
    end
    
    Then "there should be a new reward assigned to the story and linking to me and the creator" do
      @reward = Reward.last
      assert_equal @user, @reward.user
      assert_equal @story.user, @reward.recipient
      assert_equal @story, @reward.story
      assert_equal 1, @reward.amount
    end
    
    And "the story's reward count should be one higher" do
      @story.reload
      assert_equal @old_reward_count + 1, @story.reward_count.to_i
    end
  end
  
end
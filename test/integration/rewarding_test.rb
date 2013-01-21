require 'test_helper'
include ActionView::Helpers::TextHelper

Feature "A user should be able to reward a creator" do

  in_order_to "show my support and appreciation for a creator's work"
  as_a "user"
  i_want_to "be able to reward the creator"

  Scenario "Rewarding a creator" do
    given_a(:user)
    given_a(:creator)
    given_im_signed_in_as(:user)
    
    When "I view the reward modal" do
      visit reward_user_path(@creator)
      @old_reward_count = @creator.lifetime_rewards.to_i
    end
    
    And "I choose the one dollar reward and submit" do
      # Since the reward modal loads in a lightbox iframe and I want to avoid having to
      # make this a Selenium test (eww), I'm just visiting the reward modal path directly
      visit reward_user_path(@creator)
      page.find("#one-dollar-reward").click
      click_button "Give Reward"
    end
    
    Then "there should be a new reward linking to me and the creator" do
      @reward = Reward.last
      assert_equal @user, @reward.user
      assert_equal @creator, @reward.recipient
      assert_equal 1, @reward.amount
    end
    
    And "the creator's reward count should be one higher" do
      @creator.reload
      assert_equal @old_reward_count + 1, @creator.lifetime_rewards.to_i
    end
  end
  
end
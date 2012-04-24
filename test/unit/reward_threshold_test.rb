require 'test_helper'

class RewardThresholdTest < ActiveSupport::TestCase
  
  test "A new user has an unfunded reward threshold of one dollar" do
    user = Factory(:email_confirmed_user)
    assert_equal 1.0, user.unfunded_reward_threshold
  end
  
  test "A user who rewards an amount under their threshold can continue to reward" do
    user = Factory(:email_confirmed_user)
    story = Factory(:story)
    user.reward(story, 0.90, "")
    assert user.is_under_unfunded_threshold?
    assert user.reward(story, 0.20, "")
  end
  
  test "A user who rewards an amount pushing them over their threshold can no longer reward" do
    user = Factory(:email_confirmed_user)
    story = Factory(:story)
    user.reward(story, 1.20, "")
    assert !user.is_under_unfunded_threshold?
    assert !user.reward(story, 0.20, "")
  end
  
  test "Once a user pays for their unfunded rewards, their threshold resets" do
    user = Factory(:email_confirmed_user)
    story = Factory(:story)
    user.reward(story, 1.20, "")
    assert !user.is_under_unfunded_threshold?
    user.pay_for_unfunded_rewards!
    assert user.is_under_unfunded_threshold?
    assert user.reward(story, 0.20, "")
  end
  
end
require 'test_helper'

class RewardThresholdTest < ActiveSupport::TestCase
  
  test "A new user has an unfunded reward threshold of one dollar" do
    user = Factory(:email_confirmed_user)
    assert_equal 1, user.unfunded_reward_threshold
  end
  
  test "A user who rewards an amount under their threshold can continue to reward" do
    user = Factory(:email_confirmed_user)
    story = Factory(:story)
    #user.reward(story, )
  end
  
  test "A user who rewards an amount pushing them over their threshold can no longer reward"
  
  test "Once a user pays for their unfunded rewards, their threshold resets"
  
end
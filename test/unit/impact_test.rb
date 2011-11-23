require 'test_helper'

class ImpactTest < ActiveSupport::TestCase
  
  test "A reward has an impact score based on the sum of its amount + its descendants' reward amounts" do
    parent_reward = Factory(:reward, :amount => 1)
  
    user = Factory(:user_with_coins)    
    child_reward = user.reward(parent_reward.story, 5, "", parent_reward.id)
    grandchild_reward = user.reward(child_reward.story, 3, "", child_reward.id)
    
    parent_reward.reload
    child_reward.reload
    assert_equal child_reward.amount + grandchild_reward.amount, child_reward.impact
    assert_equal parent_reward.amount + child_reward.amount + grandchild_reward.amount, parent_reward.impact
  end
  
  test "When a user's reward was impacted by another, the ancestor user impact amounts should be updated" do
    story = Factory(:story)
    impacter = Factory(:user_with_coins)

    reward = impacter.reward(story, 1, "")
    impacter.reload
    assert_equal reward.amount, impacter.impact
    
    another_user = Factory(:user_with_coins)
    child_reward = another_user.reward(story, 3, "", reward.id)
    another_user.reload
    impacter.reload
    assert_equal child_reward.amount, another_user.impact
    assert_equal reward.amount + child_reward.amount, impacter.impact
    
    # if a user re-rewards themself, they shouldn't get the double impact
    grandchild_reward = another_user.reward(story, 5, "", child_reward.id)
    another_user.reload
    impacter.reload
    assert_equal child_reward.amount + grandchild_reward.amount, another_user.impact
    assert_equal reward.amount + child_reward.amount + grandchild_reward.amount, impacter.impact
  end
  
end
require 'test_helper'

class ImpactTest < ActiveSupport::TestCase
  
  test "A reward has an impact score (based on the sum of its children reward amounts)" do
    parent_reward = Factory(:reward)
    child_reward = Factory(:reward, :amount => 5)
    child_reward.move_to_child_of(parent_reward)
    grandchild_reward = Factory(:reward, :amount => 3)
    grandchild_reward.move_to_child_of(child_reward)
    
    parent_reward.reload
    
    assert_equal 8, parent_reward.impact
  end
  
end
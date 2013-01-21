require 'test_helper'

class RewardTest < ActiveSupport::TestCase
  
  test "A creator's lifetime rewards count goes up when rewarded" do
    creator = Factory(:creator)
    user  = Factory(:user)
    
    user.reward(creator, 1)
    
    assert_equal 1, creator.lifetime_rewards
  end
  
  test "A reward's impact descendants tree is generated properly" do
    user = Factory(:user)
    creator = Factory(:creator)
    
    reward = user.reward(creator, 1)
    brother = user.reward(creator, 1, reward.id)
    sister = user.reward(creator, 1, reward.id)
    
    brother_baby1 = user.reward(creator, 1, brother.id)
    brother_baby2 = user.reward(creator, 1, brother.id)
    
    sister_baby1 = user.reward(creator, 1, sister.id)
    sister_baby2 = user.reward(creator, 1, sister.id)
    
    brother_baby3 = user.reward(creator, 1, brother.id)
    sister_baby3 = user.reward(creator, 1, sister.id)
    
    [reward,brother,sister,brother_baby1,brother_baby2,brother_baby3,sister_baby1,sister_baby2,sister_baby3].each do |r|
      r.reload
    end
    
    assert_equal 8, reward.descendants.count
    assert_equal 3, brother.descendants.count
    assert_equal 3, sister.descendants.count
  end
  
  test "A user should auto-follow a creator after rewarding them" do
    creator = Factory(:creator)
    user  = Factory(:user)
    
    user.reward(creator, 1)
    assert !Subscription.where(subscriber_id: user.id, user_id: creator.id).empty?
  end
  
  test "A reward is pledged until paid for" do
    user  = Factory(:user)
    creator = Factory(:creator)
    
    reward = user.reward(creator, 1)
    assert !reward.paid_for
  end
  
  test "An activity record is created when a user rewards" do
    user  = Factory(:user)
    creator = Factory(:creator)
    
    reward = user.reward(creator, 1)
    assert Activity.where(actor_id: user.id, recipient_id: creator.id, action_id: reward.id, action_type: "Reward").first.present?
  end
  
end
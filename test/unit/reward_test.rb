require 'test_helper'

class RewardTest < ActiveSupport::TestCase
  
  test "A content's reward count goes up when rewarded" do
    story  = Factory(:story)
    user  = Factory(:user)
    
    user.reward(story, 1)
    
    story.reload
    assert_equal 1, story.reward_count
  end
  
  test "A creator's lifetime rewards count goes up when rewarded" do
    story = Factory(:story)
    user  = Factory(:user)
    
    user.reward(story, 1)
    
    assert_equal 1, story.user.lifetime_rewards
  end
  
  test "A reward's impact descendants tree is generated properly" do
    user = Factory(:user)
    story = Factory(:story)
    
    reward = user.reward(story, 1)
    brother = user.reward(story, 1, reward.id)
    sister = user.reward(story, 1, reward.id)
    
    brother_baby1 = user.reward(story, 1, brother.id)
    brother_baby2 = user.reward(story, 1, brother.id)
    
    sister_baby1 = user.reward(story, 1, sister.id)
    sister_baby2 = user.reward(story, 1, sister.id)
    
    brother_baby3 = user.reward(story, 1, brother.id)
    sister_baby3 = user.reward(story, 1, sister.id)
    
    [reward,brother,sister,brother_baby1,brother_baby2,brother_baby3,sister_baby1,sister_baby2,sister_baby3].each do |r|
      r.reload
    end
    
    assert_equal 8, reward.descendants.count
    assert_equal 3, brother.descendants.count
    assert_equal 3, sister.descendants.count
  end
  
  test "A user should auto-follow a creator after rewarding them" do
    story = Factory(:story)
    user  = Factory(:user)
    
    user.reward(story, 1)
    assert !Subscription.where(subscriber_id: user.id, user_id: story.user_id).empty?
  end
  
  test "A reward is pledged until paid for" do
    user  = Factory(:user)
    story = Factory(:story)
    
    reward = user.reward(story, 1)
    assert !reward.paid_for
  end
  
  test "A user can pay for their rewards" do
    user  = Factory(:user)
    story = Factory(:story)
    
    user.reward(story, 1)
    # Amazon stuff happens in between here
    fake_amazon_payment_id = 1
    user.pay_for_pledged_rewards!(fake_amazon_payment_id)
    
    assert user.given_rewards.pledged.empty?
  end
  
  test "An activity record is created when a user rewards" do
    user  = Factory(:user)
    story = Factory(:story)
    
    reward = user.reward(story, 1)
    assert Activity.where(actor_id: user.id, recipient_id: story.user.id, action_id: reward.id, action_type: "Reward").first.present?
  end
  
end
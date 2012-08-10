require 'test_helper'

class ImpactTest < ActiveSupport::TestCase
  
  test "A user gets impact for promoting a reward" do
    user = Factory(:user)
    story = Factory(:story)
    reward = user.reward(story, 1)
    
    user_who_saw_tweet = Factory(:user)
    impact_reward = user_who_saw_tweet.reward(story, 1, reward.id)
    
    user.reload
    impact = reward.amount + impact_reward.amount
    assert_equal impact, user.impact
    
    user_who_saw_tweet.reload
    assert_equal impact_reward.amount, user_who_saw_tweet.impact
  end
  
  test "A reward has an impact score based on the sum of its amount + its descendants' reward amounts" do
    parent_reward = Factory(:reward, :amount => 1)
  
    user = Factory(:user_with_coins)    
    child_reward = user.reward(parent_reward.story, 5, parent_reward.id)
    grandchild_reward = user.reward(child_reward.story, 3, child_reward.id)
    
    parent_reward.reload
    child_reward.reload
    assert_equal child_reward.amount + grandchild_reward.amount, child_reward.impact
    assert_equal parent_reward.amount + child_reward.amount + grandchild_reward.amount, parent_reward.impact
  end
  
  test "When a user's reward was impacted by another, the ancestor user impact amounts should be updated" do
    story = Factory(:story)
    impacter = Factory(:user_with_coins)

    reward = impacter.reward(story, 1)
    impacter.reload
    assert_equal reward.amount, impacter.impact
    
    another_user = Factory(:user_with_coins)
    child_reward = another_user.reward(story, 3, reward.id)
    another_user.reload
    impacter.reload
    assert_equal child_reward.amount, another_user.impact
    assert_equal reward.amount + child_reward.amount, impacter.impact
    
    # if a user re-rewards themself, they shouldn't get the double impact
    grandchild_reward = another_user.reward(story, 5, child_reward.id)
    another_user.reload
    impacter.reload
    assert_equal child_reward.amount + grandchild_reward.amount, another_user.impact
    assert_equal reward.amount + child_reward.amount + grandchild_reward.amount, impacter.impact
  end
  
  test "A user's impact cache record is created and updated when they reward" do
    story = Factory(:story)
    user = Factory(:user)
    
    user.reward(story, 1)
    assert_equal 1, user.impact_on(story.user)
    assert_equal 1, story.user.impact_from(user)

    assert_equal 1, ImpactCache.count
  end
  
  test "A user's impact cache record is updated when someone rewards becuause of their promotion" do
    user  = Factory(:user)
    user2 = Factory(:user)
    story = Factory(:story)
    
    reward  = user.reward(story, 1)
    reward2 = user2.reward(story, 2, reward.id)
    
    assert_equal 3, user.impact_on(story.user)
    assert_equal 3, story.user.impact_from(user)
    
    assert_equal 2, user2.impact_on(story.user)
    assert_equal 2, story.user.impact_from(user2)
    
    assert_equal 2, ImpactCache.count
  end
  
  test "A user's impact cache is NOT updated when they reward because of their own reward" do
    user  = Factory(:user)
    story = Factory(:story)
    
    reward  = user.reward(story, 1)
    reward2 = user.reward(story, 2, reward.id)
    
    assert_equal 3, user.impact_on(story.user) # not 5, which would happen if we added impact on top
  end
  
end
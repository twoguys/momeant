require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "A creator who's work I've rewarded shows up in my rewarded creators list and I show up in their patrons list" do
    reward = Factory(:reward)
    reward.user.rewarded_creators.include?(reward.recipient)
    reward.recipient.patrons.include?(reward.user)
  end
    
  test "A creator's top supporters are the users who have impacted them most" do
    story = Factory(:story)
    user  = Factory(:user)
    user2 = Factory(:user)
    
    user.reward(story, 2)
    user2.reward(story, 1)
    
    assert_equal user,  story.user.top_supporters.first[0]
    assert_equal user2, story.user.top_supporters.last[0]
    assert_equal 2,     story.user.top_supporters.first[1]
    assert_equal 1,     story.user.top_supporters.last[1]
  end
  
  test "A user's favorite creators are the creators they've rewarded the most" do
    user    = Factory(:user)
    reward  = Factory(:reward, amount: 1, user: user)
    reward2 = Factory(:reward, amount: 2, user: user)
    
    assert_equal reward2.recipient, user.favorite_creators.first[0]
    assert_equal reward.recipient,  user.favorite_creators.last[0]
    assert_equal 2,                 user.favorite_creators.first[1]
    assert_equal 1,                 user.favorite_creators.last[1]
  end
    
end
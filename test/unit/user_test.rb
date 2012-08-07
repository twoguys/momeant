require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  test "A creator who's work I've rewarded shows up in my rewarded creators list and I show up in their patrons list" do
    reward = Factory(:reward)
    reward.user.rewarded_creators.include?(reward.recipient)
    reward.recipient.patrons.include?(reward.user)
  end
    
  test "A creator's top supporters are the users who have rewarded them most" do
    creator = Factory(:creator)
    reward  = Factory(:reward, amount: 2, recipient: creator)
    reward2 = Factory(:reward, amount: 1, recipient: creator)
    
    assert_equal reward.user,   creator.top_supporters.first[0]
    assert_equal reward2.user,  creator.top_supporters.last[0]
    assert_equal 2,             creator.top_supporters.first[1]
    assert_equal 1,             creator.top_supporters.last[1]
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

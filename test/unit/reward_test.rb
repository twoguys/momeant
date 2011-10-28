require 'test_helper'

class RewardTest < ActiveSupport::TestCase
  
  test "A reward's impact tree is generated properly" do
    user = Factory(:user_with_coins)
    story = Factory(:story)
    
    reward = user.reward(story, 1, "root")
    brother = user.reward(story, 1, "brother", reward.id)
    sister = user.reward(story, 1, "sister", reward.id)
    
    brother_baby1 = user.reward(story, 1, "brother_baby1", brother.id)
    brother_baby2 = user.reward(story, 1, "brother_baby2", brother.id)
    
    sister_baby1 = user.reward(story, 1, "sister_baby1", sister.id)
    sister_baby2 = user.reward(story, 1, "sister_baby2", sister.id)
    
    brother_baby3 = user.reward(story, 1, "brother_baby3", brother.id)
    sister_baby3 = user.reward(story, 1, "sister_baby3", sister.id)
    
    [reward,brother,sister,brother_baby1,brother_baby2,brother_baby3,sister_baby1,sister_baby2,sister_baby3].each do |r|
      r.reload
    end
    
    assert_equal 8, reward.descendants.count
    assert_equal 3, brother.descendants.count
    assert_equal 3, sister.descendants.count
    
    r = reward
    puts "root     #{r.lft} #{r.rgt} - p: #{r.parent_id}"
    r = brother
    puts "brother  #{r.lft} #{r.rgt} - p: #{r.parent_id}"
    r = brother_baby1
    puts "bbaby1   #{r.lft} #{r.rgt} - p: #{r.parent_id}"
    r = brother_baby2
    puts "bbaby2   #{r.lft} #{r.rgt} - p: #{r.parent_id}"
    r = brother_baby3
    puts "bbaby3   #{r.lft} #{r.rgt} - p: #{r.parent_id}"
    r = sister
    puts "sister   #{r.lft} #{r.rgt} - p: #{r.parent_id}"
    r = sister_baby1
    puts "sbaby1   #{r.lft} #{r.rgt} - p: #{r.parent_id}"
    r = sister_baby2
    puts "sbaby2   #{r.lft} #{r.rgt} - p: #{r.parent_id}"
    r = sister_baby3
    puts "sbaby3   #{r.lft} #{r.rgt} - p: #{r.parent_id}"
  end
  
end
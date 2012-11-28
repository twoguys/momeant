Factory.define :reward do |reward|
  reward.user       { Factory :user }
  reward.recipient  { Factory :creator }
  reward.amount     1
  reward.impact     1
  reward.story      { |r| Factory :story, :user => r.recipient }
  reward.paid_for   true
end

Factory.define :unfunded_reward, :parent => :reward do |reward|
  reward.paid_for   false
end

Factory.define :thank_you_level do |level|
  level.user          { Factory :creator }
  level.amount        50
  level.item          "Screen printed poster"
  level.description   "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt."
end
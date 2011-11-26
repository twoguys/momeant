Factory.define :reward do |reward|
  reward.user       { Factory :user }
  reward.recipient  { Factory :creator }
  reward.amount     1
  reward.impact     1
  reward.story      { |r| Factory :story, :user => r.recipient }
end
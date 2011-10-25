Factory.define :pay_period do |pay_period|
  pay_period.end        { 1.month.ago }
  pay_period.user       { Factory(:admin) }
  #pay_period.line_items { [Factory(:line_item), Factory(:line_item), Factory(:line_item)] }
end

Factory.define :requested_cashout do |cashout|
  cashout.user      { Factory(:creator) }
  cashout.rewards   { |c| [Factory(:reward, :amount => 50, :user => c.user), Factory(:reward, :amount => 50, :user => c.user)]}
end
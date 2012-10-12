Factory.define :pay_period do |pay_period|
  pay_period.end        { 1.month.ago }
  pay_period.user       { Factory(:admin) }
  pay_period.line_items { [Factory(:pay_period_line_item), Factory(:pay_period_line_item)] }
end

Factory.define :pay_period_line_item do |line_item|
  line_item.payee   { Factory(:creator) }
  line_item.amount  10
end
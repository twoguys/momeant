Factory.define :purchase do |purchase|
  purchase.story    { Factory(:story) }
  purchase.payee    { |p| p.story.user }
  purchase.payer    { Factory(:email_confirmed_user) }
  purchase.amount   { |p| p.story.price }
end

Factory.define :pay_period do |pay_period|
  pay_period.end        { 1.month.ago }
  pay_period.user       { Factory(:admin) }
  #pay_period.line_items { [Factory(:line_item), Factory(:line_item), Factory(:line_item)] }
end

Factory.define :line_item, :class => "PayPeriodLineItem" do |line_item|
  line_item.purchases   { [Factory(:purchase)] }
  line_item.payee       { |l| l.purchases.first.payee }
  line_item.amount      { |l| l.purchases.first.amount }
end

Factory.define :credit_card do |c|
  c.number                "5105105105105100"
  c.month                 "12"
  c.year                  { (Date.today.year + 10).to_s }
  c.cvv                   "123"
end
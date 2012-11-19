Factory.define :pay_period do |pay_period|
  pay_period.end        { 1.month.ago }
  pay_period.user       { Factory(:admin) }
  pay_period.line_items { [Factory(:pay_period_line_item), Factory(:pay_period_line_item)] }
end

Factory.define :pay_period_line_item do |line_item|
  line_item.payee   { Factory(:creator) }
  line_item.amount  10
end

Factory.define :amazon_payment do |payment|
  payment.amount                  1
  payment.amazon_transaction_id   SecureRandom.hex(18)[0,35]
  payment.used_for                "Pay"
  payment.payer                   { Factory(:postpaid_user) }
end

Factory.define :amazon_settle_payment, parent: :amazon_payment do |payment|
  payment.used_for                "SettleDebt"
end
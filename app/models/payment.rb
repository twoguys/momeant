class Payment < Transaction
  has_one :line_item, :class_name => "PayPeriodLineItem"
  has_one :pay_period, :through => :line_item
end
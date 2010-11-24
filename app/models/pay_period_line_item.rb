class PayPeriodLineItem < ActiveRecord::Base
  belongs_to :payee, :class_name => "User"
  belongs_to :pay_period
end
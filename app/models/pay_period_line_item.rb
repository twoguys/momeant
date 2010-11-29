class PayPeriodLineItem < ActiveRecord::Base
  belongs_to :payee, :class_name => "User"
  belongs_to :pay_period
  has_many :purchases
  belongs_to :payment
  
  validates_presence_of :payee, :amount
end
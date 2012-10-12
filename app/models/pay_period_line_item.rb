class PayPeriodLineItem < ActiveRecord::Base
  belongs_to :pay_period
  belongs_to :payee, :class_name => "User"
  has_many :rewards
  
  validates_presence_of :payee, :amount
  
  default_scope order("created_at ASC")
end
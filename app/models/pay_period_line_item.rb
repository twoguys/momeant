class PayPeriodLineItem < ActiveRecord::Base
  belongs_to :pay_period
  belongs_to :payee, :class_name => "User"
  belongs_to :payment, :dependent => :destroy
  has_many :rewards
  
  validates_presence_of :payee, :amount
end
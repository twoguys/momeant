class Transaction < ActiveRecord::Base
  belongs_to :payer, :class_name => "User"
  belongs_to :payee, :class_name => "User"
end

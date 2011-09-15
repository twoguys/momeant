class Transaction < ActiveRecord::Base
  include AASM
  
  belongs_to :payer, :class_name => "User"
  belongs_to :payee, :class_name => "User"
  
  # STATE MACHINE FOR PAYMENTS
  
  aasm_column :state

  aasm_initial_state :started

  aasm_state :started
  aasm_state :accepted
  aasm_state :paid
  aasm_state :failed
  
  aasm_event :accept do
    transitions :to => :accepted, :from => :started
  end
end

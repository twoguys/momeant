class Cashout < ActiveRecord::Base
  include AASM
  
  belongs_to :user
  belongs_to :pay_period
  has_many :rewards
  
  aasm_column :state
  aasm_initial_state :requested

  aasm_state :requested
  aasm_state :paid
  
end

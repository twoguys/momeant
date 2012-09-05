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
  
  aasm_event :mark_as_paid do
    transitions :to => :paid, :from => :accepted
  end
  
  # Reports -------------------------------------------------------------------------
  
  def self.per_day(time)
    by_day = self.where(created_at: (time.ago..Time.now)).group("date_trunc('day',created_at)").reorder("").sum(:amount)
    (time.ago.to_date..Date.today).to_a.map do |date|
      Rails.logger.info by_day[date.beginning_of_day.to_s(:db)].to_i
      by_day[date.beginning_of_day.to_s(:db)].to_i
    end
  end
  
end

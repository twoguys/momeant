class Transaction < ActiveRecord::Base
  include AASM
  
  belongs_to :payer, :class_name => "User"
  belongs_to :payee, :class_name => "User"
  
  # STATE MACHINE FOR PAYMENTS
  
  aasm_column :state

  aasm_initial_state :pending

  aasm_state :pending
  aasm_state :success
  aasm_state :failure
  
  # Reports -------------------------------------------------------------------------
  
  def self.per_day(time)
    by_day = self.where(created_at: (time.ago..Time.now)).group("date_trunc('day',created_at)").reorder("").sum(:amount)
    (time.ago.to_date..Date.today).to_a.map do |date|
      Rails.logger.info by_day[date.beginning_of_day.to_s(:db)].to_i
      by_day[date.beginning_of_day.to_s(:db)].to_i
    end
  end
  
end

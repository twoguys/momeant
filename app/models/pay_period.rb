require 'csv'

class PayPeriod < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :user # admin that ended the period
  has_many :line_items, class_name: "PayPeriodLineItem"
  has_many :rewards, :through => :line_items
  has_many :creators, :through => :line_items, :source => :payee
  
  PAYOUT_THRESHOLD = 10
  CREATOR_CUT = 0.8
  
  def print_date
    self.end.strftime("%m/%d/%Y")
  end
  
  def to_csv
    CSV.generate do |csv|
      csv << ["Pay Period ending #{self.print_date}", "", "Total: #{number_to_currency(self.amount)}"]
      self.line_items.each do |line_item|
        csv << [ line_item.payee.name, line_item.payee.pay_email, number_to_currency(line_item.amount) ]
      end
    end
  end
  
  def amount
    self.line_items.sum(:amount)
  end
  
  def self.end_now(user)
    creators = Reward.momeant_needs_to_pay.group_by(&:recipient) # Find creators BEFORE creating the next pay period (since it grabs all paid rewards since the last pay period)
    pay_period = PayPeriod.create(user_id: user.id, end: Time.now)
    
    creators.reject { |creator, rewards| rewards.map(&:amount).inject(:+) < PayPeriod::PAYOUT_THRESHOLD }.each do |creator, rewards|
      line_item = PayPeriodLineItem.create(
        pay_period_id: pay_period.id,
        payee_id: creator.id,
        amount: rewards.map(&:amount).inject(:+) * PayPeriod::CREATOR_CUT
      )
      Reward.where(id: rewards.map(&:id)).update_all(pay_period_line_item_id: line_item.id)
      NotificationsMailer.payment_notice(creator, line_item.amount).deliver
    end
    
    pay_period
  end
end
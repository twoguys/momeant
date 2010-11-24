class PayPeriod < ActiveRecord::Base
  belongs_to :user # admin that ended the period
  has_many :line_items, :class_name => "PayPeriodLineItem"
  
  def create_line_items
    previous_pay_period = PayPeriod.where("created_at < ?", self.created_at).order("created_at DESC").limit(1).first
    if previous_pay_period
      purchases = Purchase.after(previous_pay_period.created_at)
    else
      purchases = Purchase.all
    end
    
    creator_ids = purchases.map {|p| p.payee_id}.uniq
    creator_ids.each do |creator_id|
      creator_purchases_total = purchases.reject {|p| p.payee_id != creator_id}.map {|p| p.amount}.inject {|sum, price| sum + price}
      self.line_items << PayPeriodLineItem.new(:payee_id => creator_id, :amount => creator_purchases_total)
    end
  end
  
  def total
    self.line_items.map {|l| l.amount}.inject {|sum, price| sum + price}
  end
end
class PayPeriod < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
  belongs_to :user # admin that ended the period
  has_many :line_items, :class_name => "PayPeriodLineItem", :dependent => :destroy
  has_many :purchases, :through => :line_items
  has_many :payees, :through => :line_items
  has_many :payments, :through => :line_items
  
  def create_line_items
    purchases = Purchase.where(:pay_period_line_item_id => nil)
    creator_ids = purchases.map {|p| p.payee_id}.uniq
    
    creator_ids.each do |creator_id|
      creator_sales = purchases.reject {|p| p.payee_id != creator_id}
      creator_purchases_total = creator_sales.map {|p| p.amount}.inject {|sum, price| sum + price}
      line_item = PayPeriodLineItem.new(:payee_id => creator_id, :amount => creator_purchases_total)
      if self.line_items << line_item
        # associate the purchases with this line item
        line_item_id = PayPeriodLineItem.last.id
        creator_sales_ids = creator_sales.map{|sale| sale.id}.join(",")
        Purchase.update_all("pay_period_line_item_id = #{line_item_id}", "id IN (#{creator_sales_ids})")
      end
    end
  end
  
  def total
    self.line_items.map {|l| l.amount}.inject {|sum, price| sum + price} || 0.0
  end
  
  def print_date
    self.end.strftime("%m/%d/%Y")
  end
  
  def to_csv
    FasterCSV.generate do |csv|
      csv << ["Pay Period ending #{self.print_date}"]
      self.line_items.each do |line_item|
        csv << [number_to_currency(line_item.amount), line_item.payee.name] unless line_item.amount == 0
      end
    end
  end
  
  def mark_as_paid
    self.line_items.each do |line_item|
      payment = Payment.create(:payee_id => line_item.payee_id, :amount => line_item.amount, :pay_period_line_item_id => line_item.id)
      line_item.update_attribute(:payment_id, payment.id)
    end
    self.update_attribute(:paid, true)
  end
end
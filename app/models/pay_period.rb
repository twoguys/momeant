class PayPeriod < ActiveRecord::Base
  include ActionView::Helpers::NumberHelper
  
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
      creator_sales = purchases.reject {|p| p.payee_id != creator_id}
      creator_purchases_total = creator_sales.map {|p| p.amount}.inject {|sum, price| sum + price}
      line_item = PayPeriodLineItem.new(:payee_id => creator_id, :amount => creator_purchases_total)
      if self.line_items << line_item
        Rails.logger.info "----------LINE ITEM ID: #{line_item.id}------------"
        # associate the purchases with this line item
        creator_sales_ids = creator_sales.map{|sale| sale.id}.join(",")
        Purchase.update_all("pay_period_line_item_id = #{line_item.id}", "id IN (#{creator_sales_ids})")
      end
    end
  end
  
  def total
    self.line_items.map {|l| l.amount}.inject {|sum, price| sum + price}
  end
  
  def print_date
    self.end.strftime("%m/%d/%Y")
  end
  
  def to_csv
    FasterCSV.generate do |csv|
      csv << ["Pay Period ending #{self.print_date}"]
      self.line_items.each do |line_item|
        csv << [line_item.payee.name, number_to_currency(line_item.amount)] unless line_item.amount == 0
      end
    end
  end
end
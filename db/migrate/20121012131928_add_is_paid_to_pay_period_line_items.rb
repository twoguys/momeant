class AddIsPaidToPayPeriodLineItems < ActiveRecord::Migration
  def self.up
    add_column :pay_period_line_items, :is_paid, :boolean, default: false
  end

  def self.down
    remove_column :pay_period_line_items, :is_paid
  end
end

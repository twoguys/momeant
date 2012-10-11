class AddPayPeriodLineItemIdToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :pay_period_line_item_id, :integer
  end

  def self.down
    remove_column :curations, :pay_period_line_item_id
  end
end

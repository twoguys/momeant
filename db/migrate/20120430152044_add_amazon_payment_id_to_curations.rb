class AddAmazonPaymentIdToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :amazon_payment_id, :integer
  end

  def self.down
    remove_column :curations, :amazon_payment_id
  end
end

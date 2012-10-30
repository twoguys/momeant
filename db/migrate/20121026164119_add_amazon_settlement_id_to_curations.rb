class AddAmazonSettlementIdToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :amazon_settlement_id, :integer
  end

  def self.down
    remove_column :curations, :amazon_settlement_id
  end
end

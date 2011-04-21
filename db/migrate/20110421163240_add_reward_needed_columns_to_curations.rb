class AddRewardNeededColumnsToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :amount, :integer, :default => 0
    add_column :curations, :recipient_id, :integer
  end

  def self.down
    remove_column :curations, :recipient_id
    remove_column :curations, :amount
  end
end

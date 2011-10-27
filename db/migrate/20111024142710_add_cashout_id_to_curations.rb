class AddCashoutIdToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :cashout_id, :integer
  end

  def self.down
    remove_column :curations, :cashout_id
  end
end
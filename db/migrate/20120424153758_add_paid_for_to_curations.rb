class AddPaidForToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :paid_for, :boolean, :default => false
    Reward.update_all(:paid_for => true)
  end

  def self.down
    remove_column :curations, :paid_for
  end
end

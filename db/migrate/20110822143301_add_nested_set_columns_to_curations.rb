class AddNestedSetColumnsToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :parent_id, :integer
    add_column :curations, :lft, :integer
    add_column :curations, :rgt, :integer
    add_column :curations, :depth, :integer, :default => 0
    Reward.update_all(:depth => 0)
  end

  def self.down
    remove_column :curations, :rgt
    remove_column :curations, :lft
    remove_column :curations, :parent_id
    remove_column :curations, :depth
  end
end

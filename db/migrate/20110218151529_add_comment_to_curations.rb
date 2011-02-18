class AddCommentToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :comment, :text
  end

  def self.down
    remove_column :curations, :comment
  end
end

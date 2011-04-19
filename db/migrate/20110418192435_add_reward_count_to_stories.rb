class AddRewardCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :reward_count, :integer, :default => 0
    Story.update_all(:reward_count => 0)
  end

  def self.down
    remove_column :stories, :reward_count
  end
end

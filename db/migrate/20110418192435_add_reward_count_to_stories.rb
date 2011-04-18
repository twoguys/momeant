class AddRewardCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :reward_count, :integer
  end

  def self.down
    remove_column :stories, :reward_count
  end
end

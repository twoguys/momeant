class AddSharedToFieldsToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :shared_to_twitter, :boolean, :default => false
    add_column :curations, :shared_to_facebook, :boolean, :default => false
  end

  def self.down
    remove_column :curations, :shared_to_facebook
    remove_column :curations, :shared_to_twitter
  end
end

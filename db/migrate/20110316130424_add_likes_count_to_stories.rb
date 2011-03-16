class AddLikesCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :likes_count, :integer, :default => 0
    
    Story.reset_column_information
    Story.find_each do |s|
      Story.reset_counters s.id, :likes
    end
  end

  def self.down
    remove_column :stories, :likes_count
  end
end

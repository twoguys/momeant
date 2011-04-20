class AddViewCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :view_count, :integer, :default => 0
    Story.update_all(:view_count => 0)
  end

  def self.down
    remove_column :stories, :view_count
  end
end

class AddPublishedToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :published, :boolean, :default => false
    Story.update_all(:published => true)
  end

  def self.down
    remove_column :stories, :published
  end
end

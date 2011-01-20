class AddThumbnailPageToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :thumbnail_page, :integer
    Story.update_all(:thumbnail_page => 1)
  end

  def self.down
    remove_column :stories, :thumbnail_page
  end
end

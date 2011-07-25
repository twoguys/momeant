class AddGalleryIdToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :gallery_id, :integer
  end

  def self.down
    remove_column :stories, :gallery_id
  end
end

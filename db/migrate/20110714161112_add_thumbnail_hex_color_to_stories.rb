class AddThumbnailHexColorToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :thumbnail_hex_color, :string
  end

  def self.down
    remove_column :stories, :thumbnail_hex_color, :string
  end
end

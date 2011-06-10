class AddThumbnailFieldsToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :thumbnail_file_name, :string
    add_column :stories, :thumbnail_file_type, :string
    add_column :stories, :thumbnail_file_size, :integer
    add_column :stories, :thumbnail_updated_at, :datetime
  end

  def self.down
    remove_column :stories, :thumbnail_updated_at
    remove_column :stories, :thumbnail_file_size
    remove_column :stories, :thumbnail_file_type
    remove_column :stories, :thumbnail_file_name
  end
end

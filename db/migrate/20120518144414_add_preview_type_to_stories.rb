class AddPreviewTypeToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :preview_type, :string, :default => "image"
  end

  def self.down
    remove_column :stories, :preview_type
  end
end

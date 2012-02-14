class AddMediaTypeToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :media_type, :string
  end

  def self.down
    remove_column :stories, :media_type
  end
end

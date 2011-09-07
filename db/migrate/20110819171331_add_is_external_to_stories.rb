class AddIsExternalToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :is_external, :boolean, :default => false
  end

  def self.down
    remove_column :stories, :is_external
  end
end

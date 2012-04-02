class AddTemplateToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :template, :text
  end

  def self.down
    remove_column :stories, :template
  end
end

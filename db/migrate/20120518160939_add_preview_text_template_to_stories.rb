class AddPreviewTextTemplateToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :preview_text_template, :string, :default => "watchmen"
  end

  def self.down
    remove_column :stories, :preview_text_template
  end
end

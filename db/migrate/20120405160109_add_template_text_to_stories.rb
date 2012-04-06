class AddTemplateTextToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :template_text, :string
  end

  def self.down
    remove_column :stories, :template_text
  end
end

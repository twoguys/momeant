class AddTextStyleToPageMedias < ActiveRecord::Migration
  def self.up
    add_column :page_medias, :text_style, :string
  end

  def self.down
    remove_column :page_medias, :text_style
  end
end

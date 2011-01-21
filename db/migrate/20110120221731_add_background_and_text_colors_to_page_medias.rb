class AddBackgroundAndTextColorsToPageMedias < ActiveRecord::Migration
  def self.up
    add_column :page_medias, :background_color, :string
    add_column :page_medias, :text_color, :string
  end

  def self.down
    remove_column :page_medias, :text_color
    remove_column :page_medias, :background_color
  end
end

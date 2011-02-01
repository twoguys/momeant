class AddStyleColorsToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :background_color, :string
    add_column :pages, :text_color, :string
  end

  def self.down
    remove_column :pages, :text_color
    remove_column :pages, :background_color
  end
end

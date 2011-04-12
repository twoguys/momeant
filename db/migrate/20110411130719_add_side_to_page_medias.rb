class AddSideToPageMedias < ActiveRecord::Migration
  def self.up
    add_column :page_medias, :side, :string
  end

  def self.down
    remove_column :page_medias, :side
  end
end

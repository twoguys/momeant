class AddPlacementToPageMedias < ActiveRecord::Migration
  def self.up
    add_column :page_medias, :placement, :string
  end

  def self.down
    remove_column :page_medias, :placement
  end
end

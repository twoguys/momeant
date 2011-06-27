class AddDropCappedToPageMedias < ActiveRecord::Migration
  def self.up
    add_column :page_medias, :drop_capped, :boolean, :default => false
  end

  def self.down
    remove_column :page_medias, :drop_capped
  end
end

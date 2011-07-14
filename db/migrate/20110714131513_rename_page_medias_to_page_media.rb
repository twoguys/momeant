class RenamePageMediasToPageMedia < ActiveRecord::Migration
  def self.up
    rename_table(:page_medias, :page_media)
  end

  def self.down
    rename_table(:page_media, :page_medias)
  end
end

class CreatePageMedias < ActiveRecord::Migration
  def self.up
    create_table :page_medias do |t|
      t.string :type
      t.text :text
      t.string :image_file_name
      t.string :image_file_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :position
      t.integer :page_id

      t.timestamps
    end
  end

  def self.down
    drop_table :page_medias
  end
end

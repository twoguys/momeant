class CreateAdverts < ActiveRecord::Migration
  def self.up
    create_table :adverts do |t|
      t.string :title
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at
      t.string :path
      t.boolean :enabled, :default => true

      t.timestamps
    end
  end

  def self.down
    drop_table :adverts
  end
end

class CreateEditorials < ActiveRecord::Migration
  def self.up
    create_table :editorials do |t|
      t.integer :user_id
      t.text :quote
      t.boolean :published, :default => false
      t.string :show_as, :default => "creator"

      t.timestamps
    end
  end

  def self.down
    drop_table :editorials
  end
end

class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.integer :number
      t.string :type
      t.integer :story_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end

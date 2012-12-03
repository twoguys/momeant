class CreateThankYouLevels < ActiveRecord::Migration
  def self.up
    create_table :thank_you_levels do |t|
      t.decimal :amount, :precision => 8, :scale => 2
      t.string :item
      t.string :description
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :thank_you_levels
  end
end

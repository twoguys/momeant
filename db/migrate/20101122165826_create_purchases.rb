class CreatePurchases < ActiveRecord::Migration
  def self.up
    create_table :purchases do |t|
      t.integer :user_id
      t.integer :story_id
      t.float :cost

      t.timestamps
    end
  end

  def self.down
    drop_table :purchases
  end
end

class CreateCashouts < ActiveRecord::Migration
  def self.up
    create_table :cashouts do |t|
      t.integer :user_id
      t.integer :pay_period_id
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :cashouts
  end
end

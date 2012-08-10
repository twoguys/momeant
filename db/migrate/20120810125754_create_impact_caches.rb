class CreateImpactCaches < ActiveRecord::Migration
  def self.up
    create_table :impact_caches do |t|
      t.integer :user_id
      t.integer :recipient_id
      t.decimal :amount, precision: 8, scale: 2, default: 0.0

      t.timestamps
    end
  end

  def self.down
    drop_table :impact_caches
  end
end

class CreatePayPeriods < ActiveRecord::Migration
  def self.up
    create_table :pay_periods do |t|
      t.datetime :end
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pay_periods
  end
end

class CreatePayPeriodLineItems < ActiveRecord::Migration
  def self.up
    create_table :pay_period_line_items do |t|
      t.integer :payee_id
      t.integer :pay_period_id
      t.float :amount
      t.integer :payment_id

      t.timestamps
    end
  end

  def self.down
    drop_table :pay_period_line_items
  end
end

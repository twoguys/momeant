class AddPaidToPayPeriods < ActiveRecord::Migration
  def self.up
    add_column :pay_periods, :paid, :boolean, :default => false
  end

  def self.down
    remove_column :pay_periods, :paid
  end
end

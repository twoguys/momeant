class AddMoneyAvailableToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :money_available, :float, :default => 0.0
  end

  def self.down
    remove_column :users, :money_available
  end
end

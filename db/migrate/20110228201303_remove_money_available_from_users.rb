class RemoveMoneyAvailableFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :money_available
  end

  def self.down
    add_column :users, :money_available, :float, :default => 0.0
  end
end

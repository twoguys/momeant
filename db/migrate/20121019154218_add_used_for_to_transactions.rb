class AddUsedForToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :used_for, :string
  end

  def self.down
    remove_column :transactions, :used_for
  end
end

class AddStateToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :state, :string
  end

  def self.down
    remove_column :transactions, :state
  end
end

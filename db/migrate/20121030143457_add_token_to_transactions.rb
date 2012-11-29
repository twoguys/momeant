class AddTokenToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :token, :string
  end

  def self.down
    remove_column :transactions, :token
  end
end

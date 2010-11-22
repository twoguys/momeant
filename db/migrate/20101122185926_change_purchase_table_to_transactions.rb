class ChangePurchaseTableToTransactions < ActiveRecord::Migration
  def self.up
    rename_table :purchases, :transactions
    
    # renaming cost -> amount (postgres can't handle rename_column)
    remove_column :transactions, :cost
    add_column :transactions, :amount, :float
    
    # renaming user_id -> payer_id
    remove_column :transactions, :user_id
    add_column :transactions, :payee_id, :integer
    
    add_column :transactions, :payer_id, :integer
  end

  def self.down
    remove_column :transactions, :payer_id
    
    remove_column :transactions, :payee_id
    add_column :transactions, :user_id, :integer
    
    remove_column :transactions, :amount
    add_column :transactions, :cost, :float
    
    rename_table :transactions, :purchases
  end
end

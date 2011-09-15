class AddAmazonTransactionIdToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :amazon_transaction_id, :string
  end

  def self.down
    remove_column :transactions, :amazon_transaction_id
  end
end

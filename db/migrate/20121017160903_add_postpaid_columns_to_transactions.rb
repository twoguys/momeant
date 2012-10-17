class AddPostpaidColumnsToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :status_code, :string
    add_column :transactions, :credit_instrument_id, :string
    add_column :transactions, :credit_sender_token_id, :string
    add_column :transactions, :settlement_token_id, :string
  end

  def self.down
    remove_column :transactions, :status_code
    remove_column :transactions, :credit_instrument_id
    remove_column :transactions, :credit_sender_token_id
    remove_column :transactions, :settlement_token_id
  end
end

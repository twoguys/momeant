class AddPostpaidColumnsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :amazon_status_code, :string
    add_column :users, :amazon_credit_instrument_id, :string
    add_column :users, :amazon_credit_sender_token_id, :string
    add_column :users, :amazon_settlement_token_id, :string
  end

  def self.down
    remove_column :users, :amazon_status_code
    remove_column :users, :amazon_credit_instrument_id
    remove_column :users, :amazon_credit_sender_token_id
    remove_column :users, :amazon_settlement_token_id
  end
end

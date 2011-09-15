class AddAmazonTokenToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :amazon_token, :string
  end

  def self.down
    remove_column :transactions, :amazon_token
  end
end

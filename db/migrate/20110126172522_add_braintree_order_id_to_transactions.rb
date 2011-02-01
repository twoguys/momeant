class AddBraintreeOrderIdToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :braintree_order_id, :string
  end

  def self.down
    remove_column :transactions, :braintree_order_id
  end
end

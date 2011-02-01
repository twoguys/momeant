class AddStoredInBraintreeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :stored_in_braintree, :boolean, :default => false
  end

  def self.down
    remove_column :users, :stored_in_braintree
  end
end

class ChangeUsersPaypalEmailToAmazonEmail < ActiveRecord::Migration
  def self.up
    remove_column :users, :paypal_email
    add_column :users, :amazon_email, :string
  end

  def self.down
    remove_column :users, :amazon_email
    add_column :users, :paypal_email, :string
  end
end

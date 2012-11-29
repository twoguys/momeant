class AddNeedsToReauthorizeAmazonPostpaidToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :needs_to_reauthorize_amazon_postpaid, :boolean, default: false
  end

  def self.down
    remove_column :users, :needs_to_reauthorize_amazon_postpaid
  end
end

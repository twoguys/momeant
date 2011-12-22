class AddTwitterAndFacebookIdsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_id, :string
    add_column :users, :facebook_id, :string
  end

  def self.down
    remove_column :users, :facebook_id
    remove_column :users, :twitter_id
  end
end

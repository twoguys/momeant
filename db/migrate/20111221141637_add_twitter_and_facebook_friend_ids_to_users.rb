class AddTwitterAndFacebookFriendIdsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_friends, :text
    add_column :users, :facebook_friends, :text
  end

  def self.down
    remove_column :users, :facebook_friends
    remove_column :users, :twitter_friends
  end
end

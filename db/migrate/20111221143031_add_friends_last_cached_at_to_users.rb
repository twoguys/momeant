class AddFriendsLastCachedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :friends_last_cached_at, :datetime
  end

  def self.down
    remove_column :users, :friends_last_cached_at
  end
end

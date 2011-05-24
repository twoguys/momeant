class AddSubscriptionsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :subscriptions_count, :integer, :default => 0
    User.update_all(:subscriptions_count => 0)
  end

  def self.down
    remove_column :users, :subscriptions_count
  end
end
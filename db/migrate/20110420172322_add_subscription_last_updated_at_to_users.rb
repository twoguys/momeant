class AddSubscriptionLastUpdatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :subscription_last_updated_at, :datetime
    User.update_all(:subscription_last_updated_at => Time.now)
  end

  def self.down
    remove_column :users, :subscription_last_updated_at
  end
end

class AddLifetimeRewardsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :lifetime_rewards, :integer, :default => 0
    User.update_all(:lifetime_rewards => 0)
  end

  def self.down
    remove_column :users, :lifetime_rewards
  end
end

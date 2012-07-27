class AddDefaultToLifetimeRewards < ActiveRecord::Migration
  def self.up
    change_column_default :users, :lifetime_rewards, 0.0
    User.where(:lifetime_rewards => nil).update_all(:lifetime_rewards => 0.0)
  end

  def self.down
  end
end

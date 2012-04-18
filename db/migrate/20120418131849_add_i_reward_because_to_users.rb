class AddIRewardBecauseToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :i_reward_because, :string
  end

  def self.down
    remove_column :users, :i_reward_because
  end
end

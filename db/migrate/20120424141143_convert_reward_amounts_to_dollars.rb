class ConvertRewardAmountsToDollars < ActiveRecord::Migration
  def self.up
    rename_column :curations, :amount, :amount_old
    add_column :curations, :amount, :decimal, :precision => 8, :scale => 2
    Reward.update_all("amount = amount_old * #{Reward.dollar_exchange}")
    
    rename_column :stories, :reward_count, :reward_count_old
    add_column :stories, :reward_count, :decimal, :precision => 8, :scale => 2
    Story.update_all("reward_count = reward_count_old * #{Reward.dollar_exchange}")
    
    rename_column :users, :impact, :impact_old
    add_column :users, :impact, :decimal, :precision => 8, :scale => 2
    User.update_all("impact = impact_old * #{Reward.dollar_exchange}")
    
    rename_column :users, :lifetime_rewards, :lifetime_rewards_old
    add_column :users, :lifetime_rewards, :decimal, :precision => 8, :scale => 2
    User.update_all("lifetime_rewards = lifetime_rewards_old * #{Reward.dollar_exchange}")
    
    rename_column :cashouts, :amount, :amount_old
    add_column :cashouts, :amount, :decimal, :precision => 8, :scale => 2
    Cashout.update_all("amount = amount_old * #{Reward.dollar_exchange}")
  end

  def self.down
    remove_column :curations, :amount
    rename_column :curations, :amount_old, :amount
    remove_column :stories, :reward_count
    rename_column :stories, :reward_count_old, :reward_count
    remove_column :users, :impact
    rename_column :users, :impact_old, :impact
    remove_column :users, :lifetime_rewards
    rename_column :users, :lifetime_rewards_old, :lifetime_rewards
    remove_column :cashouts, :amount
    rename_column :cashouts, :amount_old, :amount
  end
end

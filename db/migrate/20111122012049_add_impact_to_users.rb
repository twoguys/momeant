class AddImpactToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :impact, :integer, :default => 0
    
    User.all.each do |user|
      impact = user.given_rewards.map {|reward| reward.descendants.sum(:amount) + reward.amount}.inject(:+) || 0
      user.update_attribute(:impact, impact)
    end
  end

  def self.down
    remove_column :users, :impact
  end
end

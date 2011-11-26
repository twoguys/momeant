class AddImpactToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :impact, :integer, :default => 0
    
    Reward.reset_column_information
    Reward.all.each do |reward|
      impact = reward.descendants.sum(:amount) + reward.amount
      reward.update_attribute(:impact, impact)
    end
  end

  def self.down
    remove_column :curations, :impact
  end
end

class AddGivenDuringTrialToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :given_during_trial, :boolean, :default => false
  end

  def self.down
    remove_column :curations, :given_during_trial
  end
end

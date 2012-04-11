class AddRewardIdToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :reward_id, :integer
  end

  def self.down
    remove_column :comments, :reward_id
  end
end

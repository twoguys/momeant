class AddCreditsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :credits, :float, :default => 0.0
  end

  def self.down
    remove_column :users, :credits
  end
end

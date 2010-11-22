class AddPurchasedCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :purchased_count, :integer, :default => 0
  end

  def self.down
    remove_column :stories, :purchased_count
  end
end

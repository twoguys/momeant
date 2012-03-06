class RemoveCategoryFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :category
  end

  def self.down
    add_column :users, :category, :string
  end
end

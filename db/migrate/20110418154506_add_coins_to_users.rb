class AddCoinsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :coins, :integer, :default => 0
    User.update_all(:coins => 10)
  end

  def self.down
    remove_column :users, :coins
  end
end

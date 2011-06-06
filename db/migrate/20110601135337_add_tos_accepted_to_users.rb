class AddTosAcceptedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tos_accepted, :boolean, :default => false
    User.update_all(:tos_accepted => true)
  end

  def self.down
    remove_column :users, :tos_accepted
  end
end

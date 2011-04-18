class AddPaidStateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :paid_state, :string
  end

  def self.down
    remove_column :users, :paid_state
  end
end

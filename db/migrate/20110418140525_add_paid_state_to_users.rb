class AddPaidStateToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :paid_state, :string
    User.update_all(:paid_state => "trial")
  end

  def self.down
    remove_column :users, :paid_state
  end
end

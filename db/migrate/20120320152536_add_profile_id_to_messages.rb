class AddProfileIdToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :profile_id, :integer
  end

  def self.down
    remove_column :messages, :profile_id
  end
end

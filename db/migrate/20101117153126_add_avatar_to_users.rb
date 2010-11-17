class AddAvatarToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :avatar_file_name, :string
    add_column :users, :avatar_file_type, :string
    add_column :users, :avatar_file_size, :integer
    add_column :users, :avatar_udpated_at, :datetime
  end

  def self.down
    remove_column :users, :avatar_udpated_at
    remove_column :users, :avatar_file_size
    remove_column :users, :avatar_file_type
    remove_column :users, :avatar_file_name
  end
end

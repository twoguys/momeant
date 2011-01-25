class SplitUsersNameToFirstNameAndLastName < ActiveRecord::Migration
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    User.all.each do |user|
      user.first_name = user.name.split(' ')[0]
      user.last_name = user.name.split(' ')[1]
      user.save
    end
    remove_column :users, :name
  end

  def self.down
    add_column :users, :name
    User.all.each do |user|
      user.name = user.first_name
      user.name << " #{user.last_name}" unless user.last_name.blank?
      user.save
    end
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end

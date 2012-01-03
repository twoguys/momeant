class AddLatitudeAndLongitudeToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
  end

  def self.down
    remove_column :users, :longitude
    remove_column :users, :latitude
  end
end

class AddOccupationToEditorials < ActiveRecord::Migration
  def self.up
    add_column :editorials, :occupation, :string
  end

  def self.down
    remove_column :editorials, :occupation
  end
end

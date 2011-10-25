class AddAmountToCashouts < ActiveRecord::Migration
  def self.up
    add_column :cashouts, :amount, :integer
  end

  def self.down
    remove_column :cashouts, :amount
  end
end

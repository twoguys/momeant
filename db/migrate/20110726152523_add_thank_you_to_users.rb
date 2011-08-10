class AddThankYouToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :thankyou, :text
  end

  def self.down
    remove_column :users, :thankyou
  end
end

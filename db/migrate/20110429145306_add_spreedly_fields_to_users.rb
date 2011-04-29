class AddSpreedlyFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :spreedly_plan, :string
    add_column :users, :spreedly_token, :string
  end

  def self.down
    remove_column :users, :spreedly_token
    remove_column :users, :spreedly_plan
  end
end

class AddTokenAndSecretToAuthentications < ActiveRecord::Migration
  def self.up
    add_column :authentications, :token, :string
    add_column :authentications, :secret, :string
  end

  def self.down
    remove_column :authentications, :secret
    remove_column :authentications, :token
  end
end

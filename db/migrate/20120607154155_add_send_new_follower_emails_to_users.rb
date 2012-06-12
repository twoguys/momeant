class AddSendNewFollowerEmailsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :send_new_follower_emails, :boolean, :default => true
    User.update_all(:send_new_follower_emails => true)
  end

  def self.down
    remove_column :users, :send_new_follower_emails
  end
end

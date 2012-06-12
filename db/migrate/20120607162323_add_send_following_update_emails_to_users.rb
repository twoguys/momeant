class AddSendFollowingUpdateEmailsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :send_following_update_emails, :boolean, :default => true
    User.update_all(:send_following_update_emails => true)
  end

  def self.down
    remove_column :users, :send_following_update_emails
  end
end

class AddNotificationSettingsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :send_reward_notification_emails, :boolean, :default => true
    add_column :users, :send_digest_emails, :boolean, :default => true
    User.update_all(:send_reward_notification_emails => true, :send_digest_emails => true)
  end

  def self.down
    remove_column :users, :send_digest_emails
    remove_column :users, :send_reward_notification_emails
  end
end

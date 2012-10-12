class AddSendImpactNotificationEmailsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :send_impact_notification_emails, :boolean, default: true
    User.update_all(send_impact_notification_emails: true)
  end

  def self.down
    remove_column :users, :send_impact_notification_emails
  end
end

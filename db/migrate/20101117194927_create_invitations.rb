class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :inviter_id
      t.boolean :accepted, :default => false
      t.string :invited_as
      t.string :invitee_email
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end

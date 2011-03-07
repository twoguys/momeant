class AddInviteeIdToInvitations < ActiveRecord::Migration
  def self.up
    add_column :invitations, :invitee_id, :integer
  end

  def self.down
    remove_column :invitations, :invitee_id
  end
end

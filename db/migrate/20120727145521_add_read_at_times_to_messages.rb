class AddReadAtTimesToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :sender_read_at, :datetime
    add_column :messages, :recipient_read_at, :datetime
  end

  def self.down
    remove_column :messages, :recipient_read_at
    remove_column :messages, :sender_read_at
  end
end

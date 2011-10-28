class Message < ActiveRecord::Base
  belongs_to :sender,
    :class_name => "User",
    :foreign_key => "sender_id"
  belongs_to :recipient,
    :class_name => "User",
    :foreign_key => "recipient_id"
  has_many :children,
    :class_name => "Message",
    :foreign_key => "parent_id"
    
  scope :already_read, where("read_at IS NOT NULL")  
  scope :unread, where("read_at IS NULL")
  
  def read!
    self.update_attribute(:read_at, Time.now)
  end
  
  def read?
    self.read_at.nil?
  end
  
  def delete_for(user)
    self.update_attribute(:sender_deleted, true) if self.sender == user
    self.update_attribute(:recipient_deleted, true) if self.recipient == user
  end
  
  def not_me(user)
    self.sender if sender != user
    self.recipient
  end
end
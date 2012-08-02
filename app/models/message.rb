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
  belongs_to :parent,
    :class_name => "Message"
    
  scope :already_read, where("read_at IS NOT NULL")  
  scope :unread, where("read_at IS NULL")
  scope :recipient_unread, where("recipient_read_at IS NULL")
  scope :in_the_past_two_weeks, where("created_at > '#{14.days.ago}'")
  
  validates_presence_of :subject, unless: Proc.new { |message| message.child? }
  validates_presence_of :body
  
  def child?
    !self.parent_id.nil?
  end
  
  def read!
    self.update_attribute(:read_at, Time.now)
  end
  
  def mark_as_unread_for(user)
    if user == self.recipient
      self.update_attribute(:recipient_read_at, nil)
    else
      self.update_attribute(:sender_read_at, nil)
    end
  end
  
  def unread_by(id)
    id == self.recipient_id ? self.recipient_read_at.nil? : self.sender_read_at.nil?
  end
  
  def delete_for(user)
    self.update_attribute(:sender_deleted, true) if self.sender == user
    self.update_attribute(:recipient_deleted, true) if self.recipient == user
  end
  
  def not_me(user)
    return self.sender if sender != user
    self.recipient
  end
  
  def involves(user)
    self.recipient_id == user.id || self.sender_id == user.id
  end
  
  def parent_or_self
    self.parent_id.nil? ? self : self.parent
  end
end
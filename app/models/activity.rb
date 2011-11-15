class Activity < ActiveRecord::Base
  belongs_to :actor, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  default_scope order("created_at DESC")
  
  scope :involving, lambda { |user| where("actor_id = ? OR recipient_id = ?", user.id, user.id) }
  scope :on_rewards, where(:action_type => "Reward")
  scope :on_content, where(:action_type => "Story")
  scope :on_purchases, where(:action_type => "AmazonPayment")
  scope :on_badges, where(:action_type => "Badge")
  
  def action
    if self.action_type == "Badge"
      return {:user_id => self.actor_id, :level => self.action_id}
    end
    
    Kernel.const_get(self.action_type).find(self.action_id)
  end
end
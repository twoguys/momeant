class Activity < ActiveRecord::Base
  belongs_to :actor, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  default_scope order("created_at DESC")
  
  scope :involving, lambda { |user| where("actor_id = ? OR recipient_id = ?", user.id, user.id) }
  scope :on_impact, where(:action_type => "Impact")
  scope :on_rewards, where(:action_type => "Reward")
  scope :on_content, where(:action_type => "Story")
  scope :on_purchases, where(:action_type => "AmazonPayment")
  scope :on_badges, where(:action_type => "Badge")
  
  paginates_per 10
  
  def action
    case self.action_type
    when "Badge"
      {:user_id => self.actor_id, :level => self.action_id}
    when "Reward"
      Reward.find(self.action_id)
    when "Impact"
      Reward.find(self.action_id)
    when "Story"
      Story.find(self.action_id)
    when "AmazonPayment"
      AmazonPayment.find(self.action_id)
    end
  end
end
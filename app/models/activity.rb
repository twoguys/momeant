class Activity < ActiveRecord::Base
  belongs_to :actor, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  
  default_scope order("created_at DESC")
  
  scope :involving, lambda { |user| where("actor_id = ? OR recipient_id = ?", user.id, user.id) }
  scope :by_users, lambda { |users| where(actor_id: users.map(&:id)) }
  scope :on_impact, where(:action_type => "Impact")
  scope :on_rewards, where(:action_type => "Reward")
  scope :on_content, where(:action_type => "Story")
  scope :on_purchases, where(:action_type => "AmazonPayment")
  scope :on_badges, where(:action_type => "Badge")
  scope :only_types, lambda { |action_types| where("action_type IN (?)", action_types) }
  scope :except_type, lambda { |action_type| where("action_type != ?", action_type) }
  scope :in_the_past_two_weeks, where("created_at > '#{14.days.ago}'")
  
  paginates_per 10
  
  def action
    case self.action_type
    when "Badge"
      {:user_id => self.actor_id, :level => self.action_id}
    when "Reward"
      Reward.find(self.action_id, :include => :user)
    when "Impact"
      Reward.find(self.action_id, :include => :user)
    when "Story"
      Story.find(self.action_id, :include => :user)
    when "AmazonPayment"
      AmazonPayment.find(self.action_id)
    when "Discussion"
      Discussion.find(self.action_id, :include => :user)
    end
  end
end
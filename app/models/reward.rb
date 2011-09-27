class Reward < Curation
  default_scope :order => 'amount DESC'
  belongs_to :story
  belongs_to :recipient, :class_name => "User"
  
  scope :for_content, where("story_id IS NOT NULL")
  scope :for_landing_page, where(:show_on_landing_page => true)
  scope :this_week, where("created_at > '#{7.days.ago}'")
  scope :this_month, where("created_at > '#{1.month.ago}'")
  
  acts_as_nested_set
  
  paginates_per 9
  
  def self.cashout_threshold
    100
  end
  
  def impact
    self.descendants.where("user_id != #{self.user_id}").sum(:amount)
  end
end
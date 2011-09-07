class Reward < Curation
  default_scope :order => 'amount DESC'
  belongs_to :story
  belongs_to :recipient, :class_name => "User"
  
  scope :for_content, where("story_id IS NOT NULL")
  
  acts_as_nested_set
  
  paginates_per 9
  
  def impact
    self.descendants.sum(:amount)
  end
end
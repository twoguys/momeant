class Reward < Curation
  default_scope :order => 'amount DESC'
  belongs_to :story
  belongs_to :recipient, :class_name => "User"
  
  scope :for_content, where("story_id IS NOT NULL")
  scope :for_landing_page, where(:show_on_landing_page => true)
  scope :this_week, where("created_at > '#{7.days.ago}'")
  scope :this_month, where("created_at > '#{1.month.ago}'")
  
  acts_as_nested_set
  
  searchable do
    text(:title) { story.title }
    text(:rewarder) { user.name }
    text(:rewardee) { recipient.name }
    text :comment
    # text :tags do
    #   story.tags.map { |tag| tag.name }
    # end
  end
  
  paginates_per 9
  
  def self.cashout_threshold
    100
  end
  
  def impact
    self.descendants.sum(:amount)
  end
  
  def descendants_tree(descendants)
    tree = {:id => self.id, :data => {:name => self.user.name, :avatar => self.user.avatar.url(:thumbnail), :comment => self.comment[0..140], :amount => self.amount}}

    tree[:children] = []
    descendants.reject{|c| c.parent_id != self.id}.each do |reward|
      tree[:children].push reward.descendants_tree(descendants)
    end
    
    tree
  end
end
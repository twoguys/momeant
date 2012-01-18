class Reward < Curation
  default_scope :order => 'amount DESC'
  belongs_to :story
  belongs_to :recipient, :class_name => "User"
  belongs_to :cashout
  
  scope :for_content, where("story_id IS NOT NULL")
  scope :for_landing_page, where(:show_on_landing_page => true)
  scope :this_week, where("created_at > '#{7.days.ago}'")
  scope :in_the_past_two_weeks, where("created_at > '#{14.days.ago}'")
  scope :this_month, where("created_at > '#{1.month.ago}'")
  scope :cashed_out, where("cashout_id IS NOT NULL")
  scope :not_cashed_out, where("cashout_id IS NULL")
  
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
  def self.dollar_exchange
    0.1
  end
  
  def descendants_tree
    comment = self.comment
    comment = "#{comment[0..120]}..." if comment.length > 120
    tree = {:id => self.id, :data => {:first_name => self.user.first_name, :last_name => self.user.last_name, :avatar => self.user.avatar.url(:large), :comment => comment, :amount => self.amount}}

    Rails.logger.info "I AM REWARD #{self.id}, adding children:"
    tree[:children] = []
    self.children.each do |reward|
      tree[:children].push reward.descendants_tree
    end
    
    tree
  end
  
  def ancestors_except(user)
    self.ancestors.map(&:user).uniq.reject {|u| u == user}
  end
  
  def descendants_except(user)
    self.descendants.map(&:user).uniq.reject {|u| u == user}
  end
end
class Reward < Curation
  default_scope :order => 'amount DESC'
  belongs_to :story
  belongs_to :recipient, :class_name => "User"
  belongs_to :cashout
  has_one :comment_object, :class_name => "Comment" # I know this is funky, but we already had a column named comment, and I can't lose that data on production
  
  scope :for_content, where("story_id IS NOT NULL")
  scope :for_landing_page, where(:show_on_landing_page => true)
  scope :this_week, where("created_at > '#{7.days.ago}'")
  scope :in_the_past_two_weeks, where("created_at > '#{14.days.ago}'")
  scope :this_month, where("created_at > '#{1.month.ago}'")
  scope :cashed_out, where("cashout_id IS NOT NULL")
  scope :not_cashed_out, where("cashout_id IS NULL")
  scope :for_user, lambda { |user| where(:recipient_id => user.id) }
  scope :but_not_for, lambda { |content| where("story_id != ?", content.id) }
  
  scope :pledged, where(:paid_for => false)
  
  before_destroy :destroy_activities
  
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
    10
  end
  
  def self.dollar_exchange
    0.1
  end
  
  def descendants_tree
    comment = self.comment
    comment = "#{comment[0..120]}..." if comment.length > 120
    tree = {:id => self.id, :data => {:first_name => self.user.first_name, :last_name => self.user.last_name, :avatar => self.user.avatar.url(:large), :comment => comment, :amount => self.amount}}

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
  
  def activities
    Activity.where(:action_id => self.id).where("action_type = 'Reward' OR action_type = 'Impact'")
  end
  
  def cache_impact!(amount = self.amount)
    impact_cache = ImpactCache.where(user_id: self.user_id, recipient_id: self.recipient_id).first
    if impact_cache
      impact_cache.increment!(:amount, amount)
    else
      ImpactCache.create(user_id: self.user_id, recipient_id: self.recipient_id, amount: self.amount)
    end
  end
  
  def give_impact_to_parents!(parent_reward)
    # make the new reward a child of the impacter reward
    self.move_to_child_of(parent_reward)
    self.update_attribute(:depth, self.ancestors.count)

    # update all ancestor rewards' impact
    self.ancestors.update_all("impact = impact + #{self.amount}")
    
    # update all ancestors' user's impact, except for this reward's user (no double points!)
    ancestor_ids = self.ancestors.map(&:user_id).uniq.reject{|user_id| user_id == self.user_id}
    unless ancestor_ids.empty?
      User.where("id in (#{ancestor_ids.join(",")})").update_all("impact = impact + #{self.amount}")
    end
    
    # record an activity for each ancestor getting impact
    self.ancestors.map(&:user_id).uniq.each do |user_id|
      if user_id != self.user_id
        Activity.create(:recipient_id => user_id, :action_type => "Impact", :action_id => self.id)
      end
    end
    
    self.ancestors.each do |reward|
      reward.cache_impact!(self.amount) unless reward.user_id == self.user_id
    end
  end
  
  # Reports -------------------------------------------------------------------------
  
  def self.per_day(time)
    by_day = self.where(created_at: (time.ago..Time.now)).group("date_trunc('day',created_at)").reorder("").sum(:amount)
    (time.ago.to_date..Date.today).to_a.map do |date|
      by_day[date.beginning_of_day.to_s(:db)].to_i
    end
  end
  
  private
  
  def destroy_activities
    self.activities.destroy_all
  end
end
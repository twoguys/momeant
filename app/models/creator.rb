class Creator < User
  has_many :created_stories, :foreign_key => :user_id, :class_name => "Story", :order => "created_at DESC"
  
  has_many :rewards, :foreign_key => :recipient_id, :order => "amount DESC"
  has_many :patrons, :through => :rewards, :source => :user, :uniq => true
  
  has_many :cashouts, :foreign_key => :user_id
  
  def media_count(type)
    self.created_stories.published.where(:media_type => type).count
  end
  
  # attr_accessor :rewards_given
  #
  # def patrons
  #   patrons = []
  #   self.rewards.group_by(&:user).each do |user, rewards|
  #     user.rewards_given = rewards.inject(0){ |sum,r| sum + r.amount }
  #     patrons << user
  #   end
  #   patrons.sort{|x,y| y.rewards_given <=> x.rewards_given}
  # end
end
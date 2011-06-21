class Creator < User
  has_many :created_stories, :foreign_key => :user_id, :class_name => "Story", :order => "created_at DESC"
  has_many :sales, :class_name => "Purchase", :foreign_key => :payee_id
  has_many :line_items, :class_name => "PayPeriodLineItem", :foreign_key => :payee_id
  has_many :payments, :foreign_key => :payee_id
  
  has_many :rewards, :foreign_key => :recipient_id, :order => "amount DESC"
  #has_many :patrons, :through => :rewards, :source => :user, :uniq => true
  
  attr_accessor :rewards_given
  
  def balance
    self.sales.sum("amount") - self.payments.sum("amount")
  end
  
  def patrons
    patrons = []
    self.rewards.group_by {|r| r.user}.each do |user, rewards|
      user.rewards_given = rewards.inject(0){ |sum,r| sum + r.amount }
      patrons << user
    end
    patrons.sort{|x,y| y.rewards_given <=> x.rewards_given}
  end
end
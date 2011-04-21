class Creator < User
  has_many :created_stories, :foreign_key => :user_id, :class_name => "Story", :order => "created_at DESC"
  has_many :sales, :class_name => "Purchase", :foreign_key => :payee_id
  has_many :line_items, :class_name => "PayPeriodLineItem", :foreign_key => :payee_id
  has_many :payments, :foreign_key => :payee_id
  
  has_many :rewards, :foreign_key => :recipient_id
  has_many :patrons, :through => :rewards, :source => :user
  
  def balance
    self.sales.sum("amount") - self.payments.sum("amount")
  end
end
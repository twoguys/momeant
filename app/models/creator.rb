class Creator < User
  has_many :created_stories, :foreign_key => :user_id, :class_name => "Story"
  has_many :sales, :class_name => "Purchase", :foreign_key => :payee_id
  has_many :line_items, :class_name => "PayPeriodLineItem", :foreign_key => :payee_id
  has_many :payments, :foreign_key => :payee_id
  
  def balance
    self.sales.sum("amount") - self.payments.sum("amount")
  end
end
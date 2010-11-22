class Creator < User
  has_many :created_stories, :foreign_key => :user_id, :class_name => "Story"
  has_many :sales, :class_name => "Transaction", :foreign_key => :payee_id
end
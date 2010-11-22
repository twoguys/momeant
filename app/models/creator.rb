class Creator < User
  has_many :created_stories, :foreign_key => "user_id", :class_name => "Story"
end
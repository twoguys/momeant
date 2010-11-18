class Creator < User
  has_many :stories, :foreign_key => "user_id"
end
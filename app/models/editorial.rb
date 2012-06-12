class Editorial < ActiveRecord::Base
  belongs_to :user
  belongs_to :story
  
  default_scope order("created_at DESC")
end
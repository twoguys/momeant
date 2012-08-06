class Discussion < ActiveRecord::Base
  acts_as_commentable
  
  belongs_to :user
end
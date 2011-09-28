class Gallery < ActiveRecord::Base
  belongs_to :user
  has_many :stories
  
  acts_as_list :scope => :user
  
  validates_presence_of :name
end

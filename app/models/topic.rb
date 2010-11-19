class Topic < ActiveRecord::Base
  has_and_belongs_to_many :stories
  
  validates :name, :presence => true, :uniqueness => true
end

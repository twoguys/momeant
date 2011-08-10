class Gallery < ActiveRecord::Base
  belongs_to :user
  has_many :stories
  
  validates_presence_of :name
end

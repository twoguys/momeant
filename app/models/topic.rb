class Topic < ActiveRecord::Base
  has_and_belongs_to_many :stories
  
  belongs_to :topic
  has_many :children, :class_name => "Topic", :foreign_key => :topic_id
  
  validates :name, :presence => true, :uniqueness => true
  
  scope :parents, where(:topic_id => nil)
end

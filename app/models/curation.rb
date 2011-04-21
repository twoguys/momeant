class Curation < ActiveRecord::Base
  belongs_to :user
  belongs_to :story
  
  scope :public, where(:type => ["Reward","Comment","Link"])
end
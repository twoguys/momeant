class Curation < ActiveRecord::Base
  belongs_to :user
  belongs_to :story
  
  scope :public, where(:type => ["Reward","Comment","Link"])
  scope :given_during_trial, where(:given_during_trial => true)
end
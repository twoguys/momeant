class Curation < ActiveRecord::Base
  default_scope :order => 'curations.created_at DESC'
  
  belongs_to :user
  belongs_to :story
  
  belongs_to :parent, class_name: "Curation"
  has_many :children, class_name: "Curation", foreign_key: "parent_id"
  
  #scope :public, where(:type => ["Reward","Comment","Link"])
  scope :given_during_trial, where(:given_during_trial => true)
  scope :past_thirty_days, where(:created_at => 30.days.ago.beginning_of_day..Time.now)
end
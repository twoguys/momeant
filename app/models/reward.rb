class Reward < Curation
  default_scope :order => 'amount DESC'
  belongs_to :story
  belongs_to :recipient, :class_name => "User"
end
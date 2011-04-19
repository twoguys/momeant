class Reward < Transaction
  default_scope :order => 'amount DESC'
  belongs_to :story
end
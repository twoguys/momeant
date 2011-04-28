class Reward < Curation
  default_scope :order => 'amount DESC'
  belongs_to :story
  belongs_to :recipient, :class_name => "User"
  
  def level
    case self.amount
    when 1
      "bronze"
    when 2
      "silver"
    when 5
      "gold"
    end
  end
end
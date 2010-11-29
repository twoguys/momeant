class Purchase < Transaction
  belongs_to :story
  belongs_to :payee, :class_name => "User"
  belongs_to :pay_period_line_item
  
  scope :after, lambda { |time| where("created_at > ?", time) }
end
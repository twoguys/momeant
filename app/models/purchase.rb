class Purchase < Transaction
  belongs_to :story
  
  scope :after, lambda { |time| where("created_at > ?", time) }
end
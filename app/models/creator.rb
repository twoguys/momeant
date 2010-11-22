class Creator < User
  has_many :created_stories, :foreign_key => "user_id", :class_name => "Story"
  
  def sales
    # this may be doable in an assocation but I couldn't think of it right away
    # also probably a better way to do it via one join instead of two selects
    Purchase.where("story_id IN (#{self.created_stories.map{|s|s.id}.join(',')})")
  end
end
class View < Curation
  
  def self.record(story, user)
    unless user.has_viewed_this_period?(story)
      View.create!(:story => story, :user => user)
      story.increment!(:view_count)
    end
  end
  
end
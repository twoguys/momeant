class View < Curation
  
  def self.record(story, user)
    unless user.has_viewed_this_period?(story)
      options = {:story => story, :user => user}
      options.merge!({:given_during_trial => true}) if user.trial?
      View.create!(options)
      story.increment!(:view_count)
    end
  end
  
end
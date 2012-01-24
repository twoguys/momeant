class DiscoveryController < ApplicationController
  
  def content
    @popular = Story.most_rewarded_in_the_past_week[0..2]
    
    if current_user
      @content_based_on_rewards = current_user.stories_tagged_similarly_to_what_ive_rewarded[0..2]
      @content_nearby = current_user.nearby_content[0..2]
    end
    
    @nav = "content"
  end
  
  def popular_content
    @popular = Story.most_rewarded_in_the_past_week
    @nav = "content"
  end
  
  def people
    
    
    @nav = "people"
  end
end
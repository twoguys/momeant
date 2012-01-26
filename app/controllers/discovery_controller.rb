class DiscoveryController < ApplicationController
  
  def content
    range = 0..7
    @popular_content = Story.most_rewarded_recently[range]
    @newest_content = Story.published.newest_first[range]
    
    @recommended_content = []
    @nearby_content = []
    @recommended_content = current_user.stories_tagged_similarly_to_what_ive_rewarded[range] if current_user
    @nearby_content = current_user.nearby_content[range] if current_user
    
    @nav = "content"
    @show_more_links = true
  end
  
  def recommended_content
    @recommended_content = []
    @recommended_content = current_user.stories_tagged_similarly_to_what_ive_rewarded if current_user
  end
  
  def popular_content
    @popular_content = Story.most_rewarded_recently[0..19]
    @nav = "content"
  end
  
  def nearby_content
    @nearby_content = []
    @nearby_content = current_user.nearby_content if current_user
  end
  
  def newest_content
    @newest_content = Story.published.newest_first.limit(20)
  end
  
  def people
    
    
    @nav = "people"
  end
end
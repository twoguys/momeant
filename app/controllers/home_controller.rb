class HomeController < ApplicationController
  
  def index
    @stories = Story.order("created_at DESC")
    if current_user
      @subscribed_to_stories = current_user.recommended_stories_from_people_i_subscribe_to
      @similar_to_bookmarked_stories = current_user.stories_similar_to_my_bookmarks_and_purchases
    end
  end
end

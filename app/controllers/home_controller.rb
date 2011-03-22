class HomeController < ApplicationController
  skip_before_filter :release_lockdown
  
  def index
    if private_beta? && current_user.nil?
      render "beta" and return
    end
    
    @stories = Story.published.newest_first
    @popular_stories = Story.published.popular
    @adverts = Advert.enabled.random.limit(2)
    if current_user
      @subscribed_to_stories = current_user.recommended_stories_from_people_i_subscribe_to
      @similar_to_bookmarked_stories = current_user.stories_similar_to_my_bookmarks_and_purchases
    end
  end
end

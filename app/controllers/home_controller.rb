class HomeController < ApplicationController
  
  def index
    @stories = Story.all
    if current_user
      @subscribed_to_stories = current_user.recommended_stories_from_people_i_subscribe_to
    end
  end
end

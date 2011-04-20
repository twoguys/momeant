class HomeController < ApplicationController
  skip_before_filter :release_lockdown
  
  def index
    if private_beta? && current_user.nil?
      render "beta" and return
    end
    
    @stories = Story.published.newest_first
    @popular_stories = Story.published.popular
    @adverts = Advert.enabled.random.limit(2)
  end
end

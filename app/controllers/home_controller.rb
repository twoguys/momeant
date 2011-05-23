class HomeController < ApplicationController
  skip_before_filter :release_lockdown
  before_filter :authenticate_user!, :only => [:subscribe]
  
  def index
    if private_beta? && current_user.nil?
      render "beta" and return
    end
    
    @most_rewarded_stories = Story.published.most_rewarded.page params[:page]
  end
end
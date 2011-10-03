class HomeController < ApplicationController
  
  def index
    @nav = "home"
    if current_user.nil?
      @background_url = "https://momeant-production.s3.amazonaws.com/assets/MomeantWallpaper0#{rand(6) + 1}.jpg"
      @hide_search = true
      render "landing" and return
    end
    
    @user = current_user
    @users = @user.rewarded_creators
    @rewards = current_user.given_rewards.for_content
    render "users/show"
  end
  
  def about
    @nav = "about"
    @nosidebar = true
  end

end
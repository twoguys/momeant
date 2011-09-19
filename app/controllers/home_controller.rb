class HomeController < ApplicationController
  
  def index
    @nav = "home"
    if current_user.nil?
      @rewards = Reward.for_landing_page.limit(3)
      @nosidebar = true
      @background_url = "https://momeant-production.s3.amazonaws.com/assets/MomeantWallpaper0#{rand(6) + 1}.jpg"
      render "landing" and return
    end
    
    @user = current_user
    @creators = current_user.given_rewards.for_content.group_by {|r| r.recipient}
    render "users/show"
  end
  
  def about
    @nav = "about"
    @nosidebar = true
  end

end
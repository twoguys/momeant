class HomeController < ApplicationController
  
  def index
    @nav = "home"
    if current_user.nil?
      @rewards = Reward.for_landing_page.limit(3)
      @body_class = "landing"
      render "landing" and return
    end
    
    @user = current_user
    @creators = current_user.given_rewards.for_content.group_by {|r| r.recipient}
    render "users/show"
  end
  
  def about
    @nav = "about"
  end
end
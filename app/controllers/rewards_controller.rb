class RewardsController < ApplicationController
  before_filter :authenticate_user!, :except => [:visualize]
  
  def create
    @user = User.find_by_id(params[:user_id])
    return if @user.nil?
    @story = Story.find_by_id(params[:reward][:story_id])
    
    @reward = current_user.reward(
      @story,
      params[:reward][:amount],
      params[:reward][:comment],
      params[:reward][:impacted_by]
    )
    
    if !@reward
      @not_enough = true
      comment = params[:reward] ? params[:reward][:comment] : ""
      @reward = Reward.new(:comment => comment)
      render :partial => "modal/form" and return
    end
        
    NotificationsMailer.reward_notice(@reward).deliver
    
    check_sharing_configured
    render :partial => "rewards/modal/after_reward"
  end
  
  def visualize
    @reward = Reward.find_by_id(params[:id])
    render :partial => "rewards/visualize", :layout => false
  end
  
  private
  
  def check_sharing_configured
    if current_user
      @twitter_configured = current_user.authentications.find_by_provider("twitter")
      @facebook_configured = current_user.authentications.find_by_provider("facebook")
    end
  end
end
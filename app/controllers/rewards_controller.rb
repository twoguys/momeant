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
      get_authentications
      render :partial => "shared/reward_modal" and return
    end
    
    sharing = params[:share]
    if sharing
      current_user.post_to_twitter(@reward, story_url(@story, :impacted_by => @reward.id)) unless sharing[:twitter].blank?
      current_user.post_to_facebook(@reward, story_url(@story, :impacted_by => @reward.id)) unless sharing[:facebook].blank?
    end
    
    Rails.logger.info "ASDFSADFSADFASDFASDFSD"
    Rails.logger.info @reward.inspect
    NotificationsMailer.reward_notice(@reward).deliver
    
    render :partial => "after_reward"
  end
  
  def visualize
    @reward = Reward.find_by_id(params[:id])
    render :partial => "rewards/visualize", :layout => false
  end
  
  private
  
  def get_authentications
    if current_user
      @twitter_auth = current_user.authentications.find_by_provider("twitter")
      @facebook_auth = current_user.authentications.find_by_provider("facebook")
    end
  end
end
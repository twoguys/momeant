class RewardsController < ApplicationController
  before_filter :authenticate_user!
  
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
    
    sharing = params[:share]
    if sharing
      current_user.post_to_twitter(@reward, story_url(@story, :impacted_by => @reward.id)) unless sharing[:twitter].blank?
      current_user.post_to_facebook(@reward, story_url(@story, :impacted_by => @reward.id)) unless sharing[:facebook].blank?
    end
    
    render :partial => "after_reward"
  end
end
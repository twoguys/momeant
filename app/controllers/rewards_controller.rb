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
    render :partial => "users/thank_you"
  end
end
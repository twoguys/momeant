class RewardsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    @user = User.find_by_id(params[:user_id])
    return if @user.nil?
    @story = Story.find_by_id(params[:story_id])
    
    @reward = current_user.reward(params[:user_id], params[:reward][:amount], params[:reward][:comment], params[:reward][:story_id])
    render :partial => "users/thank_you"
  end
end
class RewardsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_story
  
  def create
    current_user.reward(@story, params[:reward][:amount], params[:reward][:comment])
    redirect_to preview_story_path(@story)
  end
  
  private

  def find_story
    @story = Story.find(params[:story_id])
  end
end
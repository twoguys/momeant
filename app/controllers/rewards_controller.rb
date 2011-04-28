class RewardsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_story
  
  def create
    reward = current_user.reward(@story, params[:reward][:amount], params[:reward][:comment])
    render :partial => "stories/you_rewarded", :locals => {:reward => reward}
  end
  
  private

  def find_story
    @story = Story.find(params[:story_id])
  end
end
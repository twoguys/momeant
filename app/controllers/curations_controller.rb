class CurationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_story
  
  def create
    case params[:curation][:type]
    when "comment"
      if params[:curation][:comment]
        Comment.create!(:user_id => current_user.id, :story_id => @story.id, :comment => params[:curation][:comment])
        @story.increment!(:comment_count)
      end
    end
      
    redirect_to preview_story_path(@story)
  end
  
  private

  def find_story
    @story = Story.find(params[:story_id])
  end
end
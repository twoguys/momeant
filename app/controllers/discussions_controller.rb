class DiscussionsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    discussion = Discussion.new(params[:discussion])
    discussion.user = current_user
    discussion.save
    Activity.create(:actor_id => current_user.id, :action_type => "Discussion", :action_id => discussion.id)
    render partial: "discussions/discussion_summary", locals: { discussion: discussion }
  end
  
  def show
    discussion = Discussion.find(params[:id])
    render partial: "discussions/discussion", locals: { discussion: discussion }
  end
  
end
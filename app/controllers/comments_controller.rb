class CommentsController < ApplicationController
  
  def create # ajax
    comment = Comment.new(params[:comment].merge({:user_id => current_user.id}))
    comment.save
    render :partial => "comments/comment", :locals => { :user => current_user, :comment => comment }
  end
  
end
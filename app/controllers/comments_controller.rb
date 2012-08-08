class CommentsController < ApplicationController
  
  def create # ajax
    comment = Comment.new(params[:comment].merge({:user_id => current_user.id}))
    unless comment.user.can_comment_on?(comment.commentable)
      render text: "<p>Sorry, only supporters of this work can comment on it.</p>".html_safe and return
    end
    comment.save
    render :partial => "comments/comment", :locals => { :user => current_user, :comment => comment, highlight_user: comment.commentable.user }
  end
  
end
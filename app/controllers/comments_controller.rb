class CommentsController < ApplicationController
  
  def create # ajax
    comment = Comment.new(params[:comment].merge({:user_id => current_user.id}))
    if comment.commentable.is_a?(Story) && !comment.user.has_rewarded?(comment.commentable.user)
      render text: "<p>Sorry, only supporters of this work can comment on it.</p>".html_safe and return
    end
    comment.save
    render :partial => "comments/comment", :locals => { :user => current_user, :comment => comment }
  end
  
end
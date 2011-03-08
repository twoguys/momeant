class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show]
  
  def show
    @user = User.find(params[:id])
    return unless @user
    if @user.is_a?(Creator)
      @stories = @user.created_stories
      @stories = @stories.published unless @user == current_user
    else
      @stories = @user.recommended_stories
    end  
    @stories = @stories.newest_first
  end
end
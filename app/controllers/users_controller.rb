class UsersController < InheritedResources::Base
  before_filter :authenticate_user!
  
  def show
    @user = User.find(params[:id])
    return unless @user
    if @user.is_a?(Creator)
      @stories = @user.created_stories.newest_first
      @stories = @stories.published unless @user == current_user
    else
      @stories = @user.recommended_stories.newest_first
    end
  end
end
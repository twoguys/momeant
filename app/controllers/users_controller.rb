class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :billing_updates, :top_curators]
  skip_before_filter :verify_authenticity_token, :only => :billing_updates
  skip_before_filter :release_lockdown, :only => :billing_updates
  
  def top_curators
    @top_curators = User.order(:subscriptions_count).page params[:page]
    render "home/index"
  end
  
  def show
    @user = User.find(params[:id])
    return unless @user
    if @user.is_a?(Creator)
      @stories = @user.created_stories
      @stories = @stories.published unless @user == current_user
    else
      @stories = @user.rewarded_stories
    end  
    @stories = @stories.newest_first
  end
  
  def edit
    @user = current_user
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user), :notice => "Info updated!"
    else
      render 'edit'
    end
  end
  
  def billing_updates
    subscriber_ids = params[:subscriber_ids].split(",")
    subscriber_ids.each do |subscriber_id|
      user = User.find_by_id(subscriber_id)
      user.refresh_from_spreedly if user
    end

    head :ok
  end
end
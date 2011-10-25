class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :update, :analytics, :feedback]
  before_filter :find_user, :except => [:community, :community_creators, :analytics, :billing_updates, :feedback]
  skip_before_filter :verify_authenticity_token, :only => :billing_updates
  
  def show
    @users = @user.rewarded_creators
    @rewards = @user.given_rewards.for_content
    flash[:track_user_view] = true
  end
  
  def creations
    @nav = "create" if @user == current_user
  end
  
  def stream #ajax requests
    render @user.following_stream(params[:page])
  end
  
  def edit
    redirect_to edit_user_path(current_user) and return if current_user != @user
    @nav = "home"
    @sidenav = "profile"
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user), :notice => "Info updated!"
    else
      @nav = "home"
      @sidenav = "profile"
      render 'edit'
    end
  end
  
  def bookmarks
    @sidenav = "bookmarks"
  end
    
  def rewarded
    @rewards = @user.given_rewards
  end
  
  def patronage
    @users = @user.rewarded_creators
  end
  
  def followers
    @users = @user.subscribers
    @followers = true
    render "following"
  end
  
  def following
    @users = @user.subscribed_to
  end
  
  def content_rewarded_by
    @rewarder = User.find_by_id(params[:rewarder_id])
    @rewards = @rewarder.given_rewards.where(:recipient_id => @user.id)
    render :layout => false
  end
  
  def analytics
    @user = current_user
    @patrons = @user.rewards.group_by {|r| r.user_id}
    @sidenav = "analytics"
    @nav = "home"
  end
  
  def feedback
    if current_user
      FeedbackMailer.give_feedback(params[:comment], current_user).deliver
    end
    render :json => {:success => true}
  end
  
  def billing_updates
    subscriber_ids = params[:subscriber_ids].split(",")
    subscriber_ids.each do |subscriber_id|
      user = User.find_by_id(subscriber_id)
      user.refresh_from_spreedly if user
    end

    head :ok
  end
  
  private
    
    def find_user
      @user = User.find(params[:id])
      @page_title = @user.name if @user
      @nav = "home" if current_user == @user
      @sidenav = "profile" if current_user.present? && @user == current_user
    end
end
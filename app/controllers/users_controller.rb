class UsersController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :billing_updates, :top_curators]
  before_filter :get_adverts, :only => :top_curators
  before_filter :find_user, :only => [:show, :momeants, :bio, :rewarded, :patrons, :bookmarks]
  skip_before_filter :verify_authenticity_token, :only => :billing_updates
  skip_before_filter :release_lockdown, :only => :billing_updates
  
  def top_curators
    @top_curators = User.order(:subscriptions_count).page params[:page]
    render "home/index"
  end
  
  def show
  end
  
  def edit
    @user = current_user
    @nav = "home"
    @sidenav = "profile"
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to bio_user_path(@user), :notice => "Info updated!"
    else
      @nav = "home"
      @sidenav = "profile"
      render 'edit'
    end
  end
  
  def bookmarks
    @sidenav = "bookmarks"
  end
  
  def momeants
    render "show"
  end
  
  def rewarded
    @rewards = @user.given_rewards
  end
  
  def analytics
    @user = current_user
    @patrons = @user.rewards.group_by {|r| r.user_id}
    @sidenav = "analytics"
    @nav = "home"
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
      @nav = "home"
      @sidenav = "profile" if current_user.present? && @user == current_user
    end
end
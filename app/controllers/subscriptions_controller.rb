class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user, :only => [:create, :unsubscribe]
  before_filter :find_followings, :only => [:index, :work, :rewards, :discussions]
  
  def create
    existing_subscription = Subscription.where(:subscriber_id => current_user.id, :user_id => @user.id).first
    Subscription.create(:subscriber_id => current_user.id, :user_id => @user.id) unless existing_subscription
    NotificationsMailer.new_follower(@user, current_user).deliver if @user.send_new_follower_emails?
    render :json => {:success => true}
  end
  
  def unsubscribe
    Subscription.where(:subscriber_id => current_user.id, :user_id => @user.id).destroy_all
    render :json => {:success => true}
  end
  
  # Methods to support the Feed
  
  def index
    get_recent_activity
    if params[:remote]
      render partial: "subscriptions/summary"
    else
      #current_user.update_attribute(:feed_last_visited_at, Time.now)
      render "index"
    end
  end

  def user
    @user = User.find(params[:user_id])
    @activity = Activity.where(actor_id: params[:user_id], action_type: ['Story','Reward','Discussion']).order("created_at DESC")
    respond_to do |format|
      format.html { find_followings }
      format.text { render partial: "subscriptions/user.html" }
    end
  end
  
  def work
    @works = Story.published.includes(:user).where(user_id: @followings.map(&:id)).newest_first
    respond_to do |format|
      format.html
      format.text { render partial: "subscriptions/all_content.html" }
    end
  end
  
  def rewards
    @rewards = Reward.includes(:user, :story).where(user_id: @followings.map(&:id)).order("created_at DESC")
    respond_to do |format|
      format.html
      format.text { render partial: "subscriptions/all_rewards.html" }
    end
  end
  
  def discussions
    @discussions = Discussion.includes(:user).where(user_id: @followings.map(&:id)).order("created_at DESC")
    respond_to do |format|
      format.html
      format.text { render partial: "subscriptions/all_discussions.html" }
    end
  end
  
  private
  
    def find_user
      @user = User.find(params[:user_id])
    end
    
    def find_followings
      @followings = current_user.followings
    end
    
    def get_recent_activity
      since = current_user.last_sign_in_at || Time.now
      
      works = Story.published.includes(:user).where(user_id: @followings.map(&:id)).newest_first
      @works_count = works.count
      @new_works = works.where("stories.created_at > ?", since).limit(3)

      rewards = Reward.includes(:user, :story).where(user_id: @followings.map(&:id)).order("created_at DESC")
      @rewards_count = rewards.count
      @new_rewards = rewards.where("curations.created_at > ?", since).limit(3)
      
      discussions = Discussion.includes(:user).where(user_id: @followings.map(&:id)).order("created_at DESC")
      @discussions_count = discussions.count
      @new_discussions = discussions.where("discussions.created_at > ?", since).limit(3)
      
      @new_per_following = Activity.only_types(["Story","Reward"]).by_users(@followings).where("created_at > ?", since).group_by(&:actor_id)
      Rails.logger.info @new_per_following.inspect
    end
end

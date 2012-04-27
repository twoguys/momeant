class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user, :only => [:create, :unsubscribe]
  
  def index
    @nav = "following"
    @rewarded = current_user.rewarded_creators_with_amounts
    @followings = current_user.inverse_subscriptions
    get_all_activity
  end

  def filter #ajax
    if params[:id].present?
      @activity = Activity.by_users([User.find(params[:id])]).only_types(['Story','Broadcast']).order("created_at DESC")
    else
      @followings = current_user.inverse_subscriptions
      get_all_activity
    end
    render :partial => "subscriptions/list"
  end
  
  def create
    Subscription.create(:subscriber_id => current_user.id, :user_id => @user.id)
    render :json => {:success => true}
  end
  
  def unsubscribe
    Subscription.where(:subscriber_id => current_user.id, :user_id => @user.id).destroy_all
    render :json => {:success => true}
  end
  
  private
  
    def find_user
      @user = User.find(params[:user_id])
    end
    
    def get_all_activity
      @activity = Activity.where(
        "(actor_id IN (?) AND action_type IN (?)) OR (actor_id = ? AND action_type = 'Reward')",
        @followings.map(&:user_id),
        ['Story','Broadcast'],
        current_user.id
      ).order("created_at DESC")
    end
end

class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user, :only => [:create, :unsubscribe]
  
  def index
    @nav = "support"
    @creators = current_user.subscribed_to
    @activity = Activity.by_users(@creators).only_types("'Story','Broadcast'").order("created_at DESC")
  end

  def filter #ajax
    if params[:id].present?
      @activity = Activity.by_users([User.find(params[:id])]).only_types("'Story','Broadcast'").order("created_at DESC")
    else
      @activity = Activity.by_users(current_user.subscribed_to).only_types("'Story','Broadcast'").order("created_at DESC")
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
end

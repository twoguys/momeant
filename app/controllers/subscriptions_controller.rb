class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user, :only => [:create, :unsubscribe]
  
  def index
    @nav = "support"
    @creators = current_user.subscribed_to
    @content = []
    return if @creators.empty?
    @content = Story.published.newest_first.where("user_id IN (#{@creators.map(&:id).join(",")})")
  end

  def filter #ajax
    @content = User.find(params[:id]).created_stories.published.newest_first
    render :partial => "subscriptions/content", :collection => @content, :as => :content
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

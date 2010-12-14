class SubscriptionsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :find_user
  
  def create
    Subscription.create(:subscriber_id => current_user.id, :user_id => @user.id)
    redirect_to user_path(@user), :notice => "You are now subscribed to #{@user.name}."
  end
  
  def destroy
    Rails.logger.info "HIHIHIHIHI"
    Subscription.where(:subscriber_id => current_user.id, :user_id => @user.id).destroy_all
    redirect_to user_path(@user), :notice => "You are no longer subscribed to #{@user.name}."
  end
  
  private
  
    def find_user
      @user = User.find(params[:user_id])
    end
end

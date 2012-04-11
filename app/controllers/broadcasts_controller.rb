class BroadcastsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_user
  
  def create # ajax
    return if current_user != @user
    broadcast = Broadcast.new(params[:broadcast].merge(:user_id => @user.id))
    broadcast.save
    broadcast.reload
    Activity.create(:actor_id => @user.id, :action_type => "Broadcast", :action_id => broadcast.id)
    render :json => { :success => true }
  end
  
  private
  
  def find_user
    @user = User.find_by_id(params[:user_id])
  end
end
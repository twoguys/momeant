class MessagesController < ApplicationController
  before_filter :authenticate_user!, :find_user
  
  def index
    if @user == current_user
      @messages = @user.received_messages
    else
      @messages = @user.messages_from(current_user)
    end
    current_user.received_messages.unread.update_all(:read_at => Time.now) if @user == current_user
  end
  
  def create
    options = params[:message]
    options.merge!({:sender_id => current_user.id, :recipient_id => @user.id})
    @message = Message.new(options)
    if @message.save
      render :json => {:success => true, :avatar => current_user.avatar.url(:thumbnail)}
    else
      render :json => {:success => true, :message => @message.errors.full_messages}
    end
  end
  
  private
  
  def find_user
    @user = User.where(:id => params[:user_id]).first
  end
end
class MessagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :lookup_messages, only: [:index, :show, :new]
  
  def new
    @message = Message.new
    @message_user = User.find_by_id(params[:user]) if params[:user]
  end
  
  def create
    @message = Message.new(params[:message])
    @message.sender_id = current_user.id
    if @message.recipient_id == current_user.id
      flash[:alert] = "You can't message yourself, silly."
      lookup_messages
      render "new" and return
    end
    @message.sender_read_at = Time.now
    @message.recipient_read_at = Time.now if @message.parent
    if @message.save
      if @message.recipient.send_message_notification_emails?
        NotificationsMailer.message_notice(@message).deliver
      end
      if @message.parent
        @message.parent.mark_as_unread_for(@message.recipient)
      end
      if params[:remote]
        render json: {success: true, avatar: current_user.avatar.url(:thumbnail)}
      else
        redirect_to message_path(@message)
      end
    else
      if params[:remote]
        render json: {success: false, message: @message.errors.full_messages}
      else
        render "new"
      end
    end
  end
  
  def show
    @message = Message.find(params[:id])
    redirect_to messages_path unless @message.involves(current_user)
    if current_user == @message.sender
      @message.update_attribute(:sender_read_at, Time.now)
    else
      @message.update_attribute(:recipient_read_at, Time.now)
    end
    @message_list = [@message] + @message.children.order("created_at ASC")
  end
  
  def user_lookup
    @users = Sunspot.search(User) do
      keywords params[:q]
    end
    @users = @users.results.map do |user|
      { id: user.id, name: user.name, avatar: user.avatar.url(:thumbnail) }
    end
    render json: @users.to_json
  end
  
  private
  
  def lookup_messages
    @messages = current_user.messages.order("created_at DESC")
  end
end
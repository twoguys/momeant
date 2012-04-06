class MessagesController < ApplicationController
  before_filter :authenticate_user!, :find_user
  
  def index
    if @user == current_user
      @messages = @user.received_messages.map {|m| m.parent_id.nil? ? m : Message.find(m.parent_id)}.uniq
    else
      @messages = @user.messages_from(current_user).where(:recipient_id => @user.id)
    end
    current_user.received_messages.unread.update_all(:read_at => Time.now) if @user == current_user
  end
  
  def create
    options = params[:message]
    options.merge!({:sender_id => current_user.id})
    options.merge!({:recipient_id => @user.id}) unless options[:recipient_id].present?
    @message = Message.new(options)
    if @message.save
      if @user.send_message_notification_emails? && params[:public].empty?
        NotificationsMailer.message_notice(@message).deliver
      end
      render :json => {:success => true, :avatar => current_user.avatar.url(:thumbnail)}
    else
      render :json => {:success => true, :message => @message.errors.full_messages}
    end
  end
  
  def public
    return if params[:message].nil? || params[:message][:body].blank?
    @message = Message.create(
      :body => params[:message][:body],
      :sender_id => current_user.id,
      :recipient_id => @user.id,
      :profile_id => @user.id
    )
    render :partial => "users/profile_messages/message", :locals => {:message => @message}
  end
  
  private
  
  def find_user
    @user = User.where(:id => params[:user_id]).first
  end
end
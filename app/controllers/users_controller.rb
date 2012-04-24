class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :update, :update_in_place, :udpate_avatar, :analytics, :feedback, :settings, :change_password]
  before_filter :find_user, :except => [:community, :community_creators, :analytics, :billing_updates, :feedback]
  skip_before_filter :verify_authenticity_token, :only => [:billing_updates, :update_avatar]

  def index
    redirect_to root_path
  end
  
  def show
    @nav = "me" if @user == current_user
    
    if @user.is_a?(Creator)
      @content = @user.created_stories.newest_first
      @content = @content.published unless @user == current_user
      @supporters = @user.rewards.group_by(&:user).to_a.map {|x| [x.first,x.second.inject(0){|sum,r| sum+r.amount}]}.sort_by(&:second).reverse
    else
      @body_class = "patronage"
      prepare_patronage_data
      render "patronage"
    end
  end
  
  def patronage
    prepare_patronage_data
  end
  
  def patronage_filter # ajax
    @rewards = @user.given_rewards.where(:recipient_id => params[:creator_id]).includes(:story)
    render :partial => "patronage_list"
  end
  
  def activity
    @activity = Activity.by_users([@user]).only_types("'Reward','Impact'").page(params[:page])
  end
  
  def more_activity
    activity = []
    case params[:filter]
    when "all"
      activity = Activity.involving(@user)
    when "impact"
      activity = Activity.on_impact.where(:recipient_id => @user.id)
    when "rewards-given"
      activity = Activity.on_rewards.where(:actor_id => @user.id)
    when "rewards-received"
      activity = Activity.on_rewards.where(:recipient_id => @user.id)
    when "content"
      activity = Activity.on_content.involving(@user)
    when "badges"
      activity = Activity.on_badges.involving(@user)
    when "coins"
      activity = Activity.on_purchases.involving(@user)
    end
    if activity.empty?
      render :text => ""
    else
      activity = activity.page params[:page]
      render activity
    end
  end
  
  def edit
    redirect_to edit_user_path(current_user) and return if current_user != @user
    @nav = "me"
    @sidenav = "profile"
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to user_path(@user), :notice => "Info updated!"
    else
      @nav = "me"
      @sidenav = "profile"
      render 'edit'
    end
  end
  
  def update_in_place
    render :text => params[:original_value] and return if params[:update_value].blank?
    return unless ["occupation", "location", "first_name", "last_name", "email", "amazon_email", "tagline", "i_reward_because"].include?(params[:attribute])
    
    @user = current_user
    if @user.update_attribute(params[:attribute], params[:update_value])
      @user.geocode_if_location_provided if params[:attribute] == "location"
      render :text => params[:update_value]
    else
      render :text => params[:original_value]
    end
  end
  
  def update_avatar
    return if params[:avatar].blank?
    
    @user = current_user
    @user.avatar = params[:avatar]
    if @user.save
      render :json => {:result => "success", :url => @user.avatar.url(:editorial)} and return
    else
      render :json => {:result => "failure", :message => "Unable to save image"} and return
    end
  end
  
  def settings
    redirect_to settings_user_path(current_user) and return if current_user != @user
  end
  
  def update_email_setting
    return unless ["send_reward_notification_emails", "send_digest_emails", "send_message_notification_emails"].include?(params[:attribute])
    
    @user = current_user
    current_value = @user.send params[:attribute]
    @user.update_attribute(params[:attribute], !current_value)
    render :text => ""
  end
  
  def change_password
    if @user.update_with_password(params[:user])
      sign_in :user, @user, :bypass => true
      redirect_to settings_user_path(current_user)
    else
      flash[:alert] = @user.errors.full_messages
      render "settings"
    end
  end
  
  def submit_creator_request
    FeedbackMailer.creator_request(@user, params[:description], params[:examples]).deliver
    render :text => ""
  end
  
  def feedback
    if current_user
      FeedbackMailer.give_feedback(params[:comment], current_user).deliver
    end
    render :json => {:success => true}
  end
  
  private
    
    def find_user
      @user = User.find(params[:id])
      @page_title = @user.name if @user
      @nav = "me" if current_user == @user
      @sidenav = "profile" if current_user.present? && @user == current_user
    end
    
    def prepare_patronage_data
      @users = @user.given_rewards.includes(:recipient).map(&:recipient).uniq
      @rewards = []
      @rewards = @user.given_rewards.where(:recipient_id => @users.first.id).includes(:story) if @users.first
    end
end
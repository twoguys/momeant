class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:edit, :update, :update_in_place, :udpate_avatar, :analytics, :feedback, :settings, :change_password, :fund_pledged_rewards, :creator_info, :creator_payment]
  before_filter :find_user, :except => [:community, :community_creators, :analytics, :billing_updates, :feedback, :fund_pledged_rewards, :creators, :become_a_creator]
  skip_before_filter :verify_authenticity_token, :only => [:billing_updates, :update_avatar]
  skip_before_filter :creator_finished_signing_up?, :only => [:creator_info, :update_avatar]

  def index
    redirect_to root_path
  end
  
  def show
    @nav = "me" if @user == current_user
    
    if @user.is_a?(Creator)
      @content = @user.created_stories.newest_first.includes(:users_who_rewarded, :comments => [:user, :reward])
      @content = @content.published unless @user == current_user
      @discussions = @user.discussions(include: "comments")
      @discussion = @discussions.first
    end
    
    @rewards = @user.given_rewards(include: "story")
  end
  
  def reward
    @content_url = request.env["HTTP_REFERER"]
    @content_url = "http://google.com" if Rails.env.test? # hack to prevent from switching to a slow test driver
    render "rewards/modal", layout: "reward"
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
  
  def settings
    redirect_to settings_user_path(current_user) and return if current_user != @user
  end
  
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      redirect_to settings_user_path(@user), :notice => "Your settings have been updated!"
    else
      @nav = "me"
      @sidenav = "profile"
      render 'settings'
    end
  end
  
  def update_in_place
    render :text => params[:original_value] and return if params[:update_value].blank?
    return unless ["occupation", "location", "first_name", "last_name", "email", "amazon_email", "paypal_email", "tagline", "i_reward_because"].include?(params[:attribute])
    
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
  
  def update_email_setting
    return unless ["send_reward_notification_emails",
      "send_digest_emails",
      "send_new_follower_emails",
      "send_following_update_emails",
      "send_message_notification_emails",
      "send_impact_notification_emails"].include?(params[:attribute])
    
    @user = current_user
    current_value = @user.send params[:attribute]
    @user.update_attribute(params[:attribute], !current_value)
    render :text => ""
  end
  
  def change_password
    if params[:user][:password].blank?
      flash[:alert] = "Your new password cannot be blank."
      render "settings" and return
    end
    if @user.update_with_password(params[:user])
      sign_in :user, @user, :bypass => true
      redirect_to settings_user_path(@user), :notice => "Password updated!"
    else
      flash[:alert] = @user.errors.full_messages.join(", ")
      render "settings"
    end
  end
  
  def fund_pledged_rewards
    @user = current_user
    @rewards = @user.given_rewards.pledged.includes(:recipient, :story)
  end
  
  def thankyous
    @thank_you_level = ThankYouLevel.new
  end
  
  def submit_creator_request
    FeedbackMailer.creator_request(@user, params[:description], params[:examples]).deliver
    render :text => ""
  end
  
  # creator signup step 2
  def creator_info
    redirect_to root_path and return if @user != current_user
    if request.put?
      @user.update_attributes(params[:user])
      @user.errors.add(:avatar, "is required") if @user.avatar_missing?
      @user.errors.add(:tagline, "is required") if @user.tagline.blank?
      redirect_to creator_payment_path(@user) and return unless @user.avatar_missing? || @user.tagline.blank?
    end
    @nav = "signup"
  end
  
  # creator signup step 3
  def creator_payment
    redirect_to root_path and return if @user != current_user
    if request.put?
      @user.update_attributes(params[:user])
      redirect_to button_user_path(@user)
    end
    @nav = "signup"
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

end
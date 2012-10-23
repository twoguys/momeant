class RewardsController < ApplicationController
  before_filter :authenticate_user!, :except => [:visualize]
  
  def create
    @user = User.find_by_id(params[:user_id])
    return if @user.nil?
    @story = Story.find_by_id(params[:reward][:story_id])
    amount = params[:reward][:amount].gsub('$','').to_f
    
    if amount < 0.1
      render json: { success: false, error: "Sorry! $0.10 is the minimum reward allowed." } and return
    elsif amount > 99
      render json: { success: false, error: "Sorry! $99.00 is the maximum reward allowed, for now." } and return
    end
    
    begin
      @reward = current_user.reward(@story, amount, params[:reward][:impacted_by])
    rescue Exceptions::AmazonPayments::InsufficientBalanceException
      render json: { success: false, error: render_to_string(partial: "rewards/modal/errors/need_to_reauthorize") }
      return
    end
    
    if !@reward
      @error = "Oh, shoot! There was an error in processing your reward."
      render json: { success: false, error: @error } and return
    end
        
    NotificationsMailer.reward_notice(@reward).deliver if @user.send_reward_notification_emails?
    unless current_user.is_under_pledged_rewards_stop_threshold?
      previous_rewards = current_user.given_rewards.pledged.includes(:recipient)
      NotificationsMailer.pledged_limit_reached(current_user, previous_rewards).deliver
    end
    
    @twitter_configured = current_user.authentications.find_by_provider("twitter")
    @facebook_configured = current_user.authentications.find_by_provider("facebook")
    render json: { success: true, reward_id: @reward.id, html: render_to_string("rewards/modal/_after_reward", layout: false) }
  end
  
  def visualize
    @reward = Reward.find_by_id(params[:id])
    render :partial => "rewards/visualize", :layout => false
  end
end
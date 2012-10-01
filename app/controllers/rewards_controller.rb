class RewardsController < ApplicationController
  before_filter :authenticate_user!, :except => [:visualize]
  
  def create
    @user = User.find_by_id(params[:user_id])
    return if @user.nil?
    @story = Story.find_by_id(params[:reward][:story_id])
    amount = params[:reward][:amount].gsub('$','').to_f
    
    @reward = current_user.reward(
      @story,
      amount,
      params[:reward][:impacted_by]
    )
    
    if !@reward
      if !current_user.is_under_pledged_rewards_stop_threshold?
        @error = "Oops! We need you to pay for your past rewards before continuing to reward."
      else
        @error = "Sorry! That was an invalid reward amount."
      end
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
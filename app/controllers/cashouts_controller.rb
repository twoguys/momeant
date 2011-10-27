class CashoutsController < ApplicationController
  before_filter :find_user
  
  def create
    rewards = current_user.rewards.not_cashed_out
    if rewards.sum(:amount) < Reward.cashout_threshold
      redirect_to user_cashouts_path, :alert => "Sorry, you need $10 in order to cash out."
    end
    
    cashout = current_user.cashouts.create!(:amount => rewards.sum(:amount))
    cashout.reload
    rewards.update_all(:cashout_id => cashout.id)

    redirect_to user_cashouts_path
  end
  
  def update_amazon_email
    current_user.update_attribute(:amazon_email, params[:creator][:amazon_email])
    redirect_to user_cashouts_path
  end
  
  private
  
  def find_user
    @user = User.find(params[:user_id])
  end
end
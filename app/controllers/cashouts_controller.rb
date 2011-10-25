class CashoutsController < ApplicationController
  before_filter :find_user
  
  def create
    rewards = @user.rewards.not_cashed_out
    if rewards.sum(:amount) < Reward.cashout_threshold
      redirect_to user_cashouts_path, :alert => "Sorry, you do not have enough to cash out."
    end
    
    cashout = @user.cashouts.create!(:amount => rewards.sum(:amount))
    cashout.reload
    rewards.update_all(:cashout_id => cashout.id)

    redirect_to user_cashouts_path
  end
  
  private
  
  def find_user
    @user = User.find(params[:user_id])
  end
end
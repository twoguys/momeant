class ThankYouLevelsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_level, only: [:edit, :update, :destroy]
  
  def index
    @thank_you_level = ThankYouLevel.new
  end
  
  def create
    @thank_you_level = ThankYouLevel.new(params[:thank_you_level])
    if current_user.thank_you_levels << @thank_you_level
      @thank_you_level.check_for_existing_achievers
      redirect_to user_thank_you_levels_path(current_user)
    else
      @user = current_user
      render "index"
    end
  end
  
  def update
    old_amount = @thank_you_level.amount
    @thank_you_level.update_attributes(params[:thank_you_level])
    @thank_you_level.check_for_existing_achievers if @thank_you_level.amount != old_amount
    redirect_to user_thank_you_levels_path(current_user)
  end
  
  def destroy
    @thank_you_level.destroy
    redirect_to user_thank_you_levels_path(current_user)
  end
  
  private
  
  def find_level
    @thank_you_level = ThankYouLevel.find(params[:id])
  end
  
end
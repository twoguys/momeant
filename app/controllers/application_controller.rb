class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :open_reward_modal?, :creator_finished_signing_up?
  
  @nav = "home"
  @sidenav = ""
  
  def open_reward_modal?
    if params[:open_reward_modal].present?
      session[:open_reward_modal] = true
    end
  end
  
  def creator_finished_signing_up?
    return if current_user.nil?
    return unless current_user.is_a?(Creator)
    if current_user.avatar_missing? || current_user.tagline.blank?
      redirect_to creator_info_path(current_user)
    end
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  private
  
  def after_sign_in_path_for(resource)
    return root_path if session[:return_to] == new_session_url(:user)
    session[:return_to] || root_path
  end
end
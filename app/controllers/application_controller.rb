class ApplicationController < ActionController::Base
  include SslRequirement
  protect_from_forgery
  
  before_filter :open_reward_modal?
  
  @nav = "home"
  @sidenav = ""
  
  def setup_landing
    content = Story.where("user_id IN (?)", Editorial.all.map(&:user_id))
    @people = content.map(&:user).uniq.take(10)
    @nav = "home"
  end
  
  def open_reward_modal?
    if params[:open_reward_modal].present?
      session[:open_reward_modal] = true
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
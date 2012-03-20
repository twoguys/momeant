require 'pusher'

class ApplicationController < ActionController::Base
  include SslRequirement
  protect_from_forgery
  
  before_filter :push_to_sender, :create_anonymous_tracker, :open_reward_modal?
  
  @nav = "home"
  @sidenav = ""
  
  def setup_landing
    @editorials = Editorial.limit(3)
    @story = Story.where(:id => 197).first
    @story = Story.published.first if @story.nil?
    @hide_search = true if current_user.nil?
    @hide_banner = true
    @nav = "home"
  end
  
  def push_to_sender
    user = current_user ? current_user.name : ""
    Pusher['admin'].trigger('request', {:url => request.path, :user => user}) if ENV["SEND_ADMIN_LIVE_UPDATES"] == "yes"
  end
  
  def create_anonymous_tracker
    # if the user isn't logged in, set a unique cookie to track them
    if session[:analytics_anonymous_id].nil?
      session[:analytics_anonymous_id] = ActiveSupport::SecureRandom.hex(24)
    end
  end
  
  def open_reward_modal?
    if params[:open_reward_modal].present?
      session[:open_reward_modal] = true
    end
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    if exception.subject.is_a?(Story) && exception.action == :show
      if !current_user
        redirect_to preview_story_path(exception.subject), :alert => "Please login to view stories."
      elsif current_user.trial_expired?
        redirect_to preview_story_path(exception.subject), :alert => "Your trial has expired. Please subscribe to view stories."
      elsif current_user.disabled_subscription?
        redirect_to preview_story_path(exception.subject), :alert => "Your subscription is not active. Please check your settings."
      else
        redirect_to preview_story_path(exception.subject), :alert => "Sorry, that story is not published yet."
      end
    else
      redirect_to root_url, :alert => exception.message
    end
  end
  
  private
  
  def after_sign_in_path_for(resource)
    if session[:return_to] == new_session_url(:user) || session[:return_to] == root_url
      subscriptions_path
    else
      session[:return_to] || subscriptions_path
    end
  end
end
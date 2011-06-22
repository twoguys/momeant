require 'pusher'

class ApplicationController < ActionController::Base
  include SslRequirement
  protect_from_forgery
  
  before_filter :release_lockdown, :check_for_trial_expiration, :push_to_sender
  
  @nav = ""
  
  def private_beta?
    ENV["CURRENT_RELEASE"] == "private-beta"
  end
  
  def release_lockdown
    redirect_to root_path if private_beta? && current_user.nil?
  end
  
  def check_for_trial_expiration
    unless private_beta?
      if current_user && current_user.trial? && current_user.created_at < 300.days.ago
        current_user.expire_trial!
      end
    end
  end
  
  def get_adverts
    @adverts = Advert.enabled.random
    if current_user
      # TODO remove ads for non-logged in users
      @adverts = @adverts.where("path != 'invite'") if current_user.is_a?(Creator)
      @adverts = @adverts.where("path != 'subscribe'") if current_user.active_subscription?
    else
      @adverts = @adverts.where("path != 'subscribe'").where("path != 'invite'")
    end
    @adverts = @adverts.limit(2)
  end
  
  def push_to_sender
    Pusher['admin'].trigger('request', request.path)
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
    session[:return_to] || root_path
  end
end
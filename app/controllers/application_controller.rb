class ApplicationController < ActionController::Base
  include SslRequirement
  protect_from_forgery
  
  before_filter :release_lockdown, :check_for_trial_expiration
  
  def private_beta?
    ENV["CURRENT_RELEASE"] == "private-beta"
  end
  
  def release_lockdown
    redirect_to root_path if private_beta? && current_user.nil?
  end
  
  def check_for_trial_expiration
    unless private_beta?
      if current_user && current_user.trial? && current_user.created_at < 30.days.ago
        current_user.expire_trial!
      end
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
end
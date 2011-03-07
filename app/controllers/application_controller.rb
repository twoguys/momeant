class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :release_lockdown
  
  def private_beta?
    ENV["CURRENT_RELEASE"] == "private-beta"
  end
  
  def release_lockdown
    redirect_to root_path if private_beta? && current_user.nil?
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    if exception.subject.is_a?(Story) && exception.action == :show
      redirect_to preview_story_path(exception.subject), :alert => "You must first acquire this story."
    else
      redirect_to root_url, :alert => exception.message
    end
  end
end
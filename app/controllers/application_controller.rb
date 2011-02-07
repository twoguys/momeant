class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    if exception.subject.is_a?(Story) && exception.action == :show
      redirect_to preview_story_path(exception.subject), :alert => "You must first acquire this story."
    else
      redirect_to root_url, :alert => exception.message
    end
  end
end
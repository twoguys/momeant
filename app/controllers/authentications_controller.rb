class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @authentications = current_user.authentications if current_user
  end
  
  def check
    if current_user.authentications.where(:provider => params[:provider]).empty?
      render :json => false
    else
      render :json => true
    end
  end
  
  def configure
    session[:return_to] = request.referer
    redirect_to "/auth/#{params[:provider]}"
  end
  
  def create
    data = request.env["omniauth.auth"]
    auth = current_user.authentications.find_or_create_by_provider_and_uid(data["provider"], data["uid"])
    
    if data["provider"] == "twitter"
      @service = "twitter"
      auth.update_attributes(:token => data["credentials"]["token"], :secret => data["credentials"]["secret"])
    elsif data["provider"] == "facebook"
      @service = "facebook"
      auth.update_attributes(:token => data["credentials"]["token"])
    end
    
    render "shared/oauth_complete", :layout => false
  end
end
class SessionsController < Devise::SessionsController
  before_filter :store_return_to, :only => :create
  
  private
    def store_return_to
      session[:return_to] = request.referer unless request.referer == new_session_url(:user)
    end
end
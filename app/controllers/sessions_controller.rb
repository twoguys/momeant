class SessionsController < Devise::SessionsController
  before_filter :release_lockdown, :except => [:new, :create]
  before_filter :store_return_to, :only => :create
  
  private
    def store_return_to
      session[:return_to] = request.referer
    end
end
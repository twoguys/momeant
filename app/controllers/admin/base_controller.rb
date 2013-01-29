class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_admin
  before_filter :highlight_admin_nav
  
  private
    def verify_admin
      redirect_to root_path, :alert => "Sorry, you must be an admin to access that." unless current_user.is_admin?
    end
    
    def highlight_admin_nav
      @nav = "admin"
    end
end
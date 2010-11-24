class Admin::BaseController < ApplicationController
  before_filter :authenticate_user!
  before_filter :verify_admin
  
  private
    def verify_admin
      redirect_to home_path, :alert => "Sorry, you must be an admin to access that." unless current_user.is_admin?
    end
end
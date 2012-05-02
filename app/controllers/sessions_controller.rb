class SessionsController < Devise::SessionsController
  before_filter :store_return_to, :only => :create
  
  def new
    redirect_to session[:return_to] || root_path, :alert => flash.alert || ""
  end
  
  def creator
    @creator = User.new # for the adjacent signup form
    
    @login_creator = User.new(params[:user])
    invitation = Invitation.find_by_token(@login_creator.invitation_code)

    if invitation.nil? || invitation.used?
      flash[:alert] = "That invitation code is invalid."
      clean_up_passwords(@login_creator)
      render "users/creators" and return
    end
    
    existing_user = User.find_by_email(params[:user][:email])
    if existing_user.nil?
      flash[:alert] = "Invalid email address or password."
      clean_up_passwords(@login_creator)
      render "users/creators" and return
    end
    
    unless existing_user.valid_password?(params[:user][:password])
      flash[:alert] = "Invalid email address or password."
      clean_up_passwords(@login_creator)
      render "users/creators" and return
    end
    
    sign_in(:user, existing_user)
    invitation.update_attribute(:invitee_id, existing_user.id)
    redirect_to creator_info_path(existing_user)
  end
  
  private
    def store_return_to
      session[:return_to] = request.referer unless request.referer == new_session_url(:user)
    end
end
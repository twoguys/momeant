class SessionsController < Devise::SessionsController
  before_filter :store_return_to, :only => :create
  skip_before_filter :creator_finished_signing_up?, :only => :destroy
  
  def new
    redirect_to session[:return_to] || root_path, :alert => flash.alert || ""
  end
  
  def remote
    user = warden.authenticate(scope: resource_name)
    render json: { success: false } and return if user.nil?
    sign_in(:user, user)
    render json: { success: true, id: user.id, name: user.name }
  end
  
  def creator
    @creator = User.new # for the adjacent signup form
    
    @login_creator = User.new(params[:creator])
    invitation = Invitation.find_by_token(@login_creator.invitation_code)

    if invitation.nil? || invitation.used?
      flash[:alert] = "That invitation code is invalid."
      clean_up_passwords(@login_creator)
      render "users/creators" and return
    end
    
    existing_user = User.find_by_email(params[:creator][:email])
    if existing_user.nil?
      flash[:alert] = "Invalid email address or password."
      clean_up_passwords(@login_creator)
      render "users/creators" and return
    end
    
    unless existing_user.valid_password?(params[:creator][:password])
      flash[:alert] = "Invalid email address or password."
      clean_up_passwords(@login_creator)
      render "users/creators" and return
    end
    
    sign_in(:user, existing_user)
    existing_user.update_attribute(:type, "Creator")
    invitation.update_attribute(:invitee_id, existing_user.id)
    redirect_to creator_info_path(existing_user)
  end
  
  private
    def store_return_to
      session[:return_to] = request.referer unless request.referer == new_session_url(:user)
    end
end
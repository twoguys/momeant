class RegistrationsController < Devise::RegistrationsController
  
  def create
    if !session[:accepting_invitation_id].blank?
      invitation = Invitation.where(:id => session[:accepting_invitation_id]).first
      resource = Creator.new(params[:user]) if invitation && invitation.invited_as_creator?
    end
    resource ||= User.new(params[:user])
    
    if resource.save
      invitation.update_attribute(:accepted, true) if invitation
      session[:accepting_invitation_id] = nil
      if resource.active?
        set_flash_message :notice, :signed_up
        sign_in_and_redirect(resource_name, resource)
      else
        set_flash_message :notice, :inactive_signed_up
        redirect_to new_user_session_path, :notice => "You have signed up successfully. If enabled, a confirmation was sent to your e-mail."
      end
    else
      @user = resource
      clean_up_passwords(resource)
      render_with_scope :new
    end
  end
  
end
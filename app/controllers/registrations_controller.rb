class RegistrationsController < Devise::RegistrationsController
  
  def create
    resource = Creator.new(params[:user])
    resource.coins = 5
    resource.subscription_last_updated_at = Time.now
    
    if resource.save
      if private_beta?
        invitation = Invitation.find_by_token(resource.invitation_code)
        invitation.update_attribute(:invitee_id, resource.id)
      end
      
      invitation.update_attribute(:accepted, true) if invitation
      session[:accepting_invitation_id] = nil
      
      #set_flash_message :notice, :signed_up
      sign_in_and_redirect(resource_name, resource)
    else
      @user = resource
      clean_up_passwords(resource)
      if private_beta?
        render "home/beta"
      else
        render_with_scope :new
      end
    end
  end
  
end
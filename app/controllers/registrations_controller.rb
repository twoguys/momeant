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
      
      # record signup event
      Mixpanel::Tracker.new("f18bd5e5e5afaaae82315ccaef6fafb2", request.env, true)
      @mixpanel.track_event("Sign up", {:user_id => resource.id, :name => resource.name})
      
      sign_in_and_redirect(resource_name, resource)
    else
      @user = resource
      clean_up_passwords(resource)
      redirect_to root_path, :alert => @user.errors.full_messages
    end
  end
  
end
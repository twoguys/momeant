class RegistrationsController < Devise::RegistrationsController
  
  def create
    resource = User.new(params[:user])
    resource.coins = 0
    
    if resource.save
      # track signup analytics across the redirect
      flash[:track_signup] = true
      
      NotificationsMailer.welcome_to_momeant(resource).deliver
      
      sign_in_and_redirect(resource_name, resource)
    else
      @user = resource
      clean_up_passwords(resource)
      flash[:alert] = @user.errors.full_messages
      people_ids = Editorial.all.map(&:user_id).join(",")
      @people = User.where("id IN (#{people_ids})")
      render "home/index"
    end
  end
  
  def creator
    @login_creator = User.new # for the adjacent login form

    @creator = Creator.new(params[:creator])
    invitation = Invitation.find_by_token(@creator.invitation_code)
    
    if invitation.nil? || invitation.used?
      flash[:alert] = "That invitation code is invalid."
      clean_up_passwords(@creator)
      render "users/creators" and return
    end
    
    unless @creator.save
      clean_up_passwords(@creator)
      render "users/creators" and return
    end
    
    @creator.reload
    flash[:track_signup] = true # track signup analytics across the redirect
    invitation.update_attribute(:invitee_id, @creator.id)
    NotificationsMailer.welcome_to_momeant(@creator).deliver
    sign_in(:user, @creator)
    redirect_to creator_info_path(@creator)
  end
  
end
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
    @creator = Creator.new(params[:creator])
    @creator.creator_signup = true
    invitation = Invitation.find_by_token(@creator.invitation_code)
    
    if invitation.nil? || invitation.used?
      flash[:alert] = "That invitation code is invalid."
      clean_up_passwords(@creator)
      render "users/creators" and return
    end
    
    existing_user = User.find_by_email(@creator.email)
    
    if existing_user # existing patron upgrading to creator
      if !existing_user.valid_password?(params[:creator][:password])
        flash[:alert] = "Invalid password. #{link_to "Forget your password?", new_password_path(:user)}".html_safe
        clean_up_passwords(@creator)
        render "users/creators" and return
      end
      
      sign_in(:user, existing_user)
      existing_user.update_attribute(:type, "Creator")
      invitation.update_attribute(:invitee_id, existing_user.id)
      redirect_to creator_info_path(existing_user)

    elsif @creator.save # new creator, valid submission
      @creator.reload
      flash[:track_signup] = true
      invitation.update_attribute(:invitee_id, @creator.id)
      NotificationsMailer.welcome_to_momeant(@creator).deliver
      sign_in(:user, @creator)
      redirect_to creator_info_path(@creator)
    
    else # new creator, invalid submission
      clean_up_passwords(@creator)
      flash[:alert] = "Please fill out all fields and accept the ToS"
      render "users/creators"
    end
  end
  
end
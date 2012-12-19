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
    
    if @creator.save
      @creator.reload
      flash[:track_signup] = true
      NotificationsMailer.welcome_to_momeant(@creator).deliver
      sign_in(:user, @creator)
      redirect_to creator_info_path(@creator)

    else
      clean_up_passwords(@creator)
      flash[:alert] = "Please fill out all fields and accept the ToS"
      render "users/creators"
    end
  end
  
end
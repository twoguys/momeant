class InvitationsController < InheritedResources::Base
  before_filter :authenticate_user!, :except => :accept
  
  # RIGHT NOW THIS IS DEAD CODE, BUT WILL BE USED LATER WHEN CREATORS CAN INVITE USERS AGAIN
  
  def invite_creator
    authorize! :invite_creator, Invitation
    @invitation = Invitation.new(:invited_as => "Creator")
  end
  
  def create
    @invitation = Invitation.new(params[:invitation])
    if @invitation.for_creator? && cannot?(:invite_creator, Invitation)
      redirect_to root_path, :alert => "Sorry, you're not allowed to invite Creators"
      return
    end
    
    invitation = Invitation.where(:invitee_email => @invitation.invitee_email, :inviter_id => current_user.id)
    if invitation.present?
      redirect_to invite_creator_invitations_path, :notice => "Oops, you've already sent them an invite."
      return
    end

    @invitation.inviter = current_user
    if @invitation.save
      InvitationsMailer.creator_invitation(@invitation).deliver
      redirect_to invitations_path
    else
      flash[:alert] = "There were issues with your invitation."
      render "invite_creator"
    end
  end
  
  def accept
    invitation = Invitation.where(:token => params[:token]).first
    if invitation
      if current_user
        current_user.update_attribute(:type, "Creator")
        invitation.update_attribute(:accepted, true)
        redirect_to home_path, :notice => "Congratulations, you are now a creator!"
      else
        session[:accepting_invitation_id] = invitation.id
        redirect_to new_user_registration_path
      end
    else
      redirect_to root_path, :alert => "Sorry, that invitation link was invalid."
    end
  end
  
end
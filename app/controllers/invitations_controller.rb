class InvitationsController < InheritedResources::Base
  before_filter :authenticate_user!
  
  def invite_creator
    authorize! :invite_creator, Invitation
    @invitation = Invitation.new(:invited_as => "Creator")
  end
  
  def create
    @invitation = Invitation.new(params[:invitation])
    if @invitation.invited_as_creator? && !can?(:invite_creator, Invitation)
      redirect_to root_path, :alert => "Sorry, you're not allowed to invite Creators"
    else
      @invitation.inviter = current_user
      if @invitation.save
        InvitationsMailer.creator_invitation(@invitation).deliver
        redirect_to invitations_path
      else
        flash[:alert] = "There were issues with your invitation."
        render "invite_creator"
      end
    end
  end
  
  def accept
    
  end
  
end
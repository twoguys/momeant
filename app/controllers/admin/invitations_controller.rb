class Admin::InvitationsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def index
  end
  
  def create
    inv = Invitation.create(:inviter => current_user)
    redirect_to admin_invitations_path
  end
  
end
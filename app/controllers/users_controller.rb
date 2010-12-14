class UsersController < InheritedResources::Base
  before_filter :authenticate_user!
  before_filter :setup_invitation, :only => [:library, :show]
  
  def library
    @user = current_user
    render "show"
  end
  
  private
    
    def setup_invitation
      @invitation = Invitation.new(:invited_as => "Creator") if can? :invite_creator, Invitation
    end
end
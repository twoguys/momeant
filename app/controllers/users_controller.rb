class UsersController < InheritedResources::Base
  before_filter :authenticate_user!
  before_filter :find_user, :only => [:subscribe_to, :unsubscribe_from]
  before_filter :setup_invitation, :only => [:library, :show]
  
  def subscribe_to
    Subscription.create(:subscriber_id => current_user.id, :user_id => @user.id)
    redirect_to user_path(@user), :notice => "You are now subscribed to #{@user.name}."
  end
  
  def unsubscribe_from
    Subscription.where(:subscriber_id => current_user.id, :user_id => @user.id).destroy_all
    redirect_to user_path(@user), :notice => "You are no longer subscribed to #{@user.name}."
  end
  
  def library
    @user = current_user
    render "show"
  end
  
  private
  
    def find_user
      @user = User.find(params[:id])
    end
    
    def setup_invitation
      @invitation = Invitation.new(:invited_as => "Creator") if can? :invite_creator, Invitation
    end
end
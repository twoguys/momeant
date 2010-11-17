class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :destroy, :to => :modify

    if user.is_admin?  
      can :manage, :all
    elsif user.is_a?(Creator)
      can [:invite_creator, :create, :show, :index], Invitation
    else
      can [:create, :show, :index], Invitation
    end

  end
end
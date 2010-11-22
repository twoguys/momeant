class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :destroy, :to => :modify

    if user.is_admin?  
      can :manage, :all
    elsif user.is_a?(Creator)
      can [:invite_creator, :create, :show, :index], Invitation
      can :manage, Story
    else
      can [:create, :show, :index], Invitation
      can [:preview, :purchase, :library], Story
      can :show, Story do |story|
        Rails.logger.info "------------"
        Rails.logger.info user.stories.inspect
        user.stories.include?(story)
      end
    end

  end
end
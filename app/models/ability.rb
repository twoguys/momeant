class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :destroy, :to => :modify

    if user
      if user.is_admin?  
        can :manage, :all
      elsif user.is_a?(Creator)
        can [:invite_creator, :create, :show, :index], Invitation
        can :manage, Story
        can [:library, :subscribe_to, :unsubscribe_from], User
      else
        can [:create, :show, :index], Invitation
        can [:preview, :purchase, :library, :bookmark, :unbookmark, :bookmarked, :recommend, :unrecommend, :recommended], Story
        can :show, Story do |story|
          user.stories.include?(story)
        end
        can [:library, :subscribe_to, :unsubscribe_from], User
      end
    end
  end
end
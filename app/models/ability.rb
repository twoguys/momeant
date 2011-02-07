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
      else
        can [:create, :show, :index], Invitation
        can [:library, :bookmarked, :recommended], Story
        can [:purchase, :bookmark, :unbookmark, :recommend, :unrecommend, :like, :unlike], Story, :published => true
        can :preview, Story do |story|
          story.published? || story.owner?(user)
        end
        can :show, Story do |story|
          user.stories.include?(story)
        end
      end  
      can :library, User
      can :create, Subscription
      can :destroy, Subscription, :subscriber_id => user.id
    end
  end
end
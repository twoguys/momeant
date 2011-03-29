class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :destroy, :to => :modify

    if user
      
      can [:bookmarked, :recommended, :search], Story
      can [:purchase, :bookmark, :unbookmark, :recommend, :unrecommend, :like, :unlike], Story, :published => true
      can :preview, Story do |story|
        story.published? || story.owner?(user)
      end
      can :show, Story # do |story|
      #         user.stories.include?(story)
      #       end
      can :create, Subscription
      can :destroy, Subscription, :subscriber_id => user.id
      
      if user.is_a?(Creator)
        #can [:invite_creator, :create, :show, :index], Invitation
        can :manage, Story, :user_id => user.id
      end
      
      if user.is_admin?  
        can :manage, :all
      end
    end
  end
end
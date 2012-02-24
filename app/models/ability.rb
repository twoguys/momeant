class Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :update, :destroy, :to => :modify

    if user
      can [:bookmarked, :search], Story
      can [:bookmark, :unbookmark], Story, :published => true
      can :show, Story do |story|
        story.published?
      end
      
      can :manage, Story, :user_id => user.id
      
      if user.is_admin?  
        can :manage, :all
      end
    end
  end
end
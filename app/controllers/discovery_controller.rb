class DiscoveryController < ApplicationController

  def index
    @content = Story.published.most_rewarded.page(params[:page]).per(8)
    @nav = "discover"
    if params[:remote]
      render :partial => "discovery/grid_item", :collection => @content, :as => :content
      return
    else
      @activity = Activity.where("action_type = 'Reward' OR action_type = 'Story'").limit(8)
    end
  end
  
  def content
    range = 0..2
    @popular_content = Story.most_rewarded_recently[range]
    @newest_content = Story.published.newest_first[range]
    
    @recommended_content = []
    @nearby_content = []
    @recommended_content = current_user.stories_tagged_similarly_to_what_ive_rewarded[range] if current_user
    @nearby_content = current_user.nearby_content[range] if current_user
    @nav = "content"
  end
  
  def recommended_content
    @recommended_content = []
    @recommended_content = current_user.stories_tagged_similarly_to_what_ive_rewarded if current_user
    @nav = "content"
  end
  
  def popular_content
    @popular_content = Story.most_rewarded_recently[0..19]
    @nav = "content"
  end
  
  def nearby_content
    @nearby_content = []
    @nearby_content = current_user.nearby_content if current_user
    @nav = "content"
  end
  
  def newest_content
    @newest_content = Story.published.newest_first.limit(20)
    @nav = "content"
  end
  
  def people
    range = 0..2
    @notable_people = Editorial.limit(3)
    @top_creators = Creator.order("lifetime_rewards DESC").limit(3)
    @top_patrons = User.order("impact DESC").limit(3)
    @nav = "people"
  end
  
  def notable_people
    @notable_people = Editorial.all
    @nav = "people"
  end
  
  def friends_people
    @friends_activity = []
    @friends_activity = current_user.activity_from_twitter_and_facebook_friends if current_user
  end
  
  def reload_friends_people
    @friends_activity = []
    @friends_activity = current_user.activity_from_twitter_and_facebook_friends[0..4] if current_user
    render :partial => "friends_people"
  end
  
  def reload_friends_activity
    @friends_activity = []
    @friends_activity = current_user.activity_from_twitter_and_facebook_friends if current_user
    render @friends_activity
  end
  
  def creators_people
    @top_creators = Creator.order("lifetime_rewards DESC").where("lifetime_rewards > 0").limit(10)
    @nav = "people"
  end
  
  def patrons_people
    @top_patrons = User.order("impact DESC").where("impact > 0").limit(10)
    @nav = "people"
  end
end
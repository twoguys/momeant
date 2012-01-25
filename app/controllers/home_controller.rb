class HomeController < ApplicationController
  
  def index
    @editorials = Editorial.limit(3)
    @hide_search = true if current_user.nil?
    @hide_banner = true
    @nav = "home"
    render "landing"
  end
  
  def discover
    number_to_show = 3 # change this and they all reflect
    range = 0..(number_to_show - 1)
    
    @notable = Editorial.limit(number_to_show)
    @popular = Story.most_rewarded_in_the_past_week[range]
    @activity = Activity.except("Impact").limit(number_to_show)
    @top_patrons = User.where("impact > 0").order("impact DESC").limit(number_to_show)
    @top_creators = User.most_rewarded.limit(number_to_show)
    
    if current_user
      @activity_from_friends = current_user.activity_from_twitter_and_facebook_friends[range]
      @content_based_on_rewards = current_user.stories_tagged_similarly_to_what_ive_rewarded[range]
      @content_nearby = current_user.nearby_content[range]
    end
  end
  
  def about
    @nav = "about"
    @nosidebar = true
  end
  
  def faq
    redirect_to about_path
  end

end
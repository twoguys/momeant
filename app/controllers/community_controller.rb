class CommunityController < ApplicationController
  before_filter :set_nav
  
  def index
    @activity = Activity.page params[:page]
    respond_to do |format|
      format.html { render "index" }
      format.js { render @activity }
    end
  end
  
  def content
    @stories = Story.published.most_rewarded.limit(12)

    if params[:tag]
      @stories = @stories.tagged_with(params[:tag])
    else
      @tags = Story.tag_counts.order("count DESC").limit(10)
    end
    
    @page_title = "Most Rewarded Content"
    @stories = @stories.page(params[:page]).per(24)
  end
  
  def rewards
    @activity = Activity.on_rewards.page params[:page]
    respond_to do |format|
      format.html { render "rewards" }
      format.js { render @activity }
    end
  end
  
  def people
    content_ids = get_tags_and_stories
    
    @users = User.select("DISTINCT ON(id) users.*").joins("LEFT OUTER JOIN curations ON curations.user_id = users.id").where("curations.type = 'Reward'").where("curations.story_id IN (#{content_ids.join(',')})")
    # this sort is going to make A LOT of SQL calls, need to cache impact on the user
    @users = @users.sort do |a,b|
      if a.badge_level != b.badge_level
        b.badge_level <=> a.badge_level
      else
        b.impact <=> a.impact
      end
    end
    @users = @users[0..15]
    
    @page_title = "Most Impactful People"
  end
  
  def newest_content
    @stories = Story.published.newest_first.limit(12)

    if params[:tag]
      @stories = @stories.tagged_with(params[:tag])
    else
      @tags = Story.tag_counts.order("count DESC").limit(10)
    end
    
    @stories = @stories.page(params[:page]).per(24)
  end
  
  private
  
  def set_nav
    @nav = "community"
  end
  
  def get_tags_and_stories
    if params[:tag].blank?
     @tags = Story.joins(:curations).where("curations.type = 'Reward'").tag_counts.order("count DESC").limit(20) 
    else      
     @tags = Story.joins(:curations).where("curations.type = 'Reward'").tagged_with(params[:tag]).tag_counts.order("count DESC").limit(10).sort do |x, y|
       if params[:tag].include?(x.name)
         -1
       else
         1
       end
     end
    end

    return Story.tagged_with(@tags, :any => true).map{|story| story.id}
  end
  
end
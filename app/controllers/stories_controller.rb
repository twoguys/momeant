class StoriesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :preview]
  load_and_authorize_resource :except => [:index, :preview]
  before_filter :get_topics, :only => [:new]
  
  def index
    @stories = Story.all
  end
  
  def library
    @stories = current_user.stories
  end
  
  def new
    @story = Story.new(:price => 0.0)
  end
  
  def create
    @story = Story.new(params[:story])
    attach_topics
    if current_user.created_stories << @story
      redirect_to preview_story_path(@story), :notice => "Great story!"
    else
      get_topics
      render "new"
    end
  end
  
  def preview
    @story = Story.find(params[:id])
  end
  
  def purchase
    if @story
      if @story.user == current_user
        redirect_to @story, :notice => "You created this story silly, you don't need to purchase it!"
      elsif current_user.stories.include?(@story)
        redirect_to @story, :notice => "You already own this story, silly!"
      elsif current_user.purchase(@story)
        PurchasesMailer.purchase_receipt(current_user, @story).deliver
        redirect_to @story, :notice => "This story is now in your library."
      else
        redirect_to deposits_path, :alert => "You need to deposit more money in order to purchase that story."
      end
    else
      redirect_to home_path, :alert => "Sorry, that story does not exist."
    end
  end
  
  def bookmark
    Bookmark.create(:story_id => @story.id, :user_id => current_user.id)
    redirect_to preview_story_path(@story), :notice => "Story bookmarked."
  end
  
  def unbookmark
    Bookmark.where(:story_id => @story.id, :user_id => current_user.id).destroy_all
    redirect_to preview_story_path(@story), :notice => "Bookmark removed."
  end
  
  def bookmarked
    @bookmarks = current_user.bookmarks
  end
  
  def recommend
    Recommendation.create(:story_id => @story.id, :user_id => current_user.id)
    redirect_to preview_story_path(@story), :notice => "Story recommended."
  end
  
  def unrecommend
    Recommendation.where(:story_id => @story.id, :user_id => current_user.id).destroy_all
    redirect_to preview_story_path(@story), :notice => "Recommendation removed."
  end
  
  def recommended
    @limit = User::RECOMMENDATIONS_LIMIT
    @recommendations = current_user.recommendations
  end
  
  def show
  end
  
  def render_page_theme
    @page_number = params[:page]
    if params[:theme] == "title-page"
      render :partial => "stories/page_themes/title_page"
    elsif params[:theme] == "full-image"
      render :partial => "stories/page_themes/full_image"
    elsif params[:theme] == "pullquote"
      render :partial => "stories/page_themes/pullquote"
    end
  end
  
  private
    
    def get_topics
      @topics = Topic.all
    end
    
    def attach_topics
      topic_ids = params[:topics]
      if topic_ids
        @story.topics << Topic.where("id IN (#{topic_ids.keys.join(',')})")
      end
    end
  
end
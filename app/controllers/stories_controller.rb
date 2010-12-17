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
    attach_pages(params[:pages])
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
    @fullscreen = true
  end
  
  def render_page_theme
    @page_number = params[:page]
    case params[:theme]
    when "title"
      render :partial => "stories/page_forms/title"
    when "full-image"
      render :partial => "stories/page_forms/full_image"
    when "pullquote"
      render :partial => "stories/page_forms/pullquote"
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
    
    def attach_pages(pages)
      return unless pages.is_a?(Hash) # TODO: check to ensure 10 pages and add errors to @story
      pages.each_pair do |number, options|
        options.merge!({:number => number})
        page_type = Page.create_page_type_with(options)
        @story.pages << page_type if page_type
      end
    end
  
end
class StoriesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :preview, :tagged_with]
  load_and_authorize_resource :except => [:index, :preview, :tagged_with]
  before_filter :get_topics, :only => [:new, :edit]
  
  def index
    @stories = Story.published
  end
  
  def library
    @stories = current_user.stories
  end
  
  def tagged_with
    @stories = []
    @tags = Story.published.tag_counts_on(:tags)
    return if params[:tag].blank?
    
    @stories = Story.published.tagged_with(params[:tag])
  end
  
  def new
    @story = Story.new(:price => 0.0)
    render "form"
  end
  
  def create
    @story = Story.new(params[:story])
    @story.published = false # draft state by default
    attach_topics
    attach_pages(params[:pages])
    if current_user.created_stories << @story
      redirect_to preview_story_path(@story), :notice => "Great story!"
    else
      get_topics
      render "form"
    end
  end
  
  def edit
    get_topics
    render "form"
  end
  
  def update
    @story.topics.destroy_all
    attach_topics
    update_pages(params[:pages])
    if @story.update_attributes(params[:story])
      redirect_to preview_story_path(@story), :notice => "Story saved."
    else
      get_topics
      render "form"
    end
  end
  
  def preview
    @story = Story.find(params[:id])
    if @story.draft? && !@story.owner?(current_user)
      redirect_to root_path, :alert => "Sorry, that story has not been published yet."
    end
  end
  
  def purchase
    if @story
      if @story.user == current_user
        redirect_to @story, :notice => "You created this story silly, you don't need to purchase it!"
      elsif current_user.stories.include?(@story)
        redirect_to @story, :notice => "You already own this story, silly!"
      elsif current_user.purchase(@story)
        PurchasesMailer.purchase_receipt(current_user, @story).deliver
        redirect_to @story
      else
        redirect_to credits_path, :alert => "You need more credits in order to purchase that story."
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
  
  def publish
    @story.update_attribute(:published, true)
    redirect_to preview_story_path(@story), :notice => "Your story has been published!"
  end
  
  def remove_tag_from
    story = Story.find_by_id(params[:id])
    render :text => "" and return if story.nil? || params[:tag].blank?
    story.tag_list.remove(params[:tag])
    story.save
    render :text => ""
  end
  
  def show
    @fullscreen = true
  end
  
  def render_page_theme
    @page_number = params[:page]
    render :partial => "stories/page_forms/#{params[:theme]}" if params[:theme]
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
      return unless pages.is_a?(Hash)
      pages.each_pair do |number, options|
        options.merge!({:number => number})
        page_type = Page.create_page_type_with(options)
        @story.pages << page_type if page_type
      end
    end
    
    def update_pages(pages)
      return unless pages.is_a?(Hash)
      pages.each_pair do |number, options|
        options.merge!({:number => number})
        Page.create_or_update_page_with(@story.page_at(number), options, @story)
      end
    end
  
end
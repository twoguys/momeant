class StoriesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :recent, :show, :tagged_with]
  load_and_authorize_resource :except => [:index, :recent, :show, :tagged_with]
  before_filter :get_topics, :only => [:new, :edit]
  before_filter :get_adverts, :only => :recent
  skip_before_filter :verify_authenticity_token, :only => [:update_thumbnail]
  
  def index
    redirect_to root_path
  end
  
  def recent
    @recent_stories = Story.published.newest_first.page params[:page]
    @nav = "home"
    render "home/index"
  end
  
  def most_rewarded
    @most_rewarded_stories = Story.published.most_rewarded.page params[:page]
    render "home/index"
  end
  
  def tagged_with
    @stories = []
    @tags = Story.published.tag_counts_on(:tags)
    return if params[:tag].blank?
    
    @stories = Story.published.tagged_with(params[:tag])
  end
  
  def show
    @story = Story.find_by_id(params[:id])
    View.record(@story, current_user) if current_user && current_user != @story.user
    @fullscreen = true
    @user = @story.user
    render :layout => false
  end
  
  def new
    @story = Story.create(:thumbnail_page => 1, :user_id => current_user.id, :autosaving => true, :price => 0)
    @nav = "create"
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
    @nav = "create"
    render "form"
  end
  
  def update
    @story.topics = []
    attach_topics
    update_pages(params[:pages])
    if @story.update_attributes(params[:story])
      redirect_to preview_story_path(@story), :notice => "Story saved."
    else
      get_topics
      render "form"
    end
  end
  
  def update_thumbnail
    return if params[:image].blank?
    
    @story.autosaving = true
    @story.thumbnail = params[:image]
    @story.determine_thumbnail_colors
    if @story.save
      render :json => {:result => "success", :thumbnail => @story.thumbnail.url(:medium)}
    else
      render :json => {:result => "failure", :message => "Unable to save image"}
    end
  end
  
  def change_to_external
    @story.pages.destroy_all
    @story.pages << ExternalPage.new(:number => 1)
    @story.update_attribute(:is_external, true)
    render :json => {:result => "success"}
  end
  
  def change_to_creator
    @story.pages.destroy_all
    @story.update_attribute(:is_external, false)
    render :json => {:result => "success"}
  end
  
  def destroy
    @story.destroy
    redirect_to user_path(current_user), :notice => "Your content was deleted."
  end
  
  def autosave
    if params[:story].blank?
      render :json => {:result => "failure", :message => "No story data sent"} and return
    end
    
    # are we updating the external link page?
    if params[:story][:external_link].present?
      external_page = @story.pages.first
      if external_page.text_media.nil?
        external_page.medias << PageText.new
      end
      link = params[:story][:external_link]
      link.gsub!(/^http:\/\//,"")
      external_page.text_media.update_attribute(:text, link)
      render :json => {:result => "success"}
      return
    end

    @story.autosaving = true
    if @story.update_attributes(params[:story])
      render :json => {:result => "success"}
    else
      render :json => {:result => "failure", :message => @story.errors.full_messages}
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
        # PurchasesMailer.purchase_receipt(current_user, @story).deliver
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
    redirect_to preview_story_path(@story)
  end
  
  def unbookmark
    Bookmark.where(:story_id => @story.id, :user_id => current_user.id).destroy_all
    redirect_to preview_story_path(@story)
  end
  
  def bookmarked
    @bookmarks = current_user.bookmarks
  end
  
  def recommend
    Recommendation.create(:story_id => @story.id, :user_id => current_user.id, :comment => params[:comment])
    redirect_to preview_story_path(@story)
  end
  
  def unrecommend
    Recommendation.where(:story_id => @story.id, :user_id => current_user.id).destroy_all
    redirect_to preview_story_path(@story)
  end
  
  def recommended
    @limit = User::RECOMMENDATIONS_LIMIT
    @stories = current_user.recommended_stories
  end
  
  def like
    Like.create(:story_id => @story.id, :user_id => current_user.id)
    redirect_to preview_story_path(@story)
  end
  
  def unlike
    Like.where(:story_id => @story.id, :user_id => current_user.id).destroy_all
    redirect_to preview_story_path(@story)
  end
  
  def publish
    if @story.valid?
      @story.update_attribute(:published, true)
      redirect_to creations_user_path(@story.user), :notice => "Your content has been published!"
    else
      redirect_to edit_story_path(@story), :alert => "Please fix the errors below."
    end
  end
  
  def remove_tag_from
    story = Story.find_by_id(params[:id])
    render :text => "" and return if story.nil? || params[:tag].blank?
    story.tag_list.remove(params[:tag])
    story.save
    render :text => ""
  end
  
  def add_topic_to
    if params[:topic_id]
      topics = Topic.where(:id => params[:topic_id])
      # add the parent topic as well, if there is one
      topics += Topic.where(:id => topics.first.topic_id) if topics.first && topics.first.topic_id
      if @story.topics << topics
        render :json => {:result => "success"}
      else  
        render :json => {:result => "failure", :message => "Unable to attach topic"}
      end
    else  
      render :json => {:result => "failure", :message => "No topic id sent"}
    end
  end
  
  def remove_topic_from
    if params[:topic_id]
      topics = Topic.where(:id => params[:topic_id])
      # remove the children topics as well, if there are any
      #topics += Topic.where(:topic_id => params[:topic_id])
      if @story.topics.delete(topics)
        render :json => {:result => "success"}
      else  
        render :json => {:result => "failure", :message => "Unable to remove topic"}
      end
    else  
      render :json => {:result => "failure", :message => "No topic id sent"}
    end
  end
  
  def render_page_form
    @page_number = params[:page]
    render :partial => "stories/page_forms/#{params[:theme]}" if params[:theme]
  end
  
  def render_page_theme
    @page_number = params[:page]
    #@page = Page.where(:story_id => params[:story_id], :number => params[:number]).first
    render :partial => "stories/page_themes/#{params[:theme]}" if params[:theme]
  end
  
  def search
    if params[:query]
      @search = Story.search do
        keywords params[:query]
        with :published, true
      end
      @stories = @search.results
    end
  end
  
  def random
    stories = Story.published
    story = stories[rand(stories.size)]
    redirect_to preview_story_path(story)
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
        Page.create_or_update_page_with(@story.page_at(number), options, @story)
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
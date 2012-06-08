class StoriesController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  load_and_authorize_resource :except => [:index, :show]
  before_filter :get_topics, :only => [:new, :edit]
  before_filter :check_sharing_configured, :only => [:new, :edit]
  skip_before_filter :verify_authenticity_token, :only => [:update_thumbnail]
  
  def index
    redirect_to root_path
  end
  
  def interesting
    @stories = Story.published.most_rewarded.page params[:page]
    @nav = "community"
  end
  
  def most_rewarded
    @most_rewarded_stories = Story.published.most_rewarded.page params[:page]
    render "home/index"
  end
  
  def show
    @story = Story.find(params[:id])
    if !@story.published? && current_user != @story.user
      redirect_to root_path, :alert => "Sorry, that story is not published yet." and return
    end
    @impacted_by = params[:impacted_by] if params[:impacted_by]
    @fullscreen = true
    
    if params[:return_to]
      @exit_presenter_url = params[:return_to]
      render "presenter" and return
    else
      @exit_presenter_url = request.env["HTTP_REFERER"]
    end
    url = URI.parse(@exit_presenter_url) unless @exit_presenter_url.nil?
    if @exit_presenter_url.nil? || !["momeant.dev","localhost","momeant.heroku.com","momeant.com"].include?(url.host) || @exit_presenter_url.include?(stories_url)
       @exit_presenter_url = root_path
    end
    
    render "presenter"
  end
  
  def new
    redirect_to become_a_creator_user_path(current_user) and return unless current_user.is_a?(Creator)

    @story = Story.create!(
      :thumbnail_page => 1,
      :user_id => current_user.id,
      :autosaving => true,
      :is_external => true,
      :title => "",
      :i_own_this => false)
    @story.pages << ExternalPage.new(:number => 1)
    @nav = "home"
    render "form"
  end
  
  def edit
    @nav = "home"
    render "form"
  end
  
  def publish
    if !@story.valid?
      redirect_to edit_story_path(@story) and return
    end
      
    unless @story.published?
      @story.update_attribute(:published, true)
      Activity.create(:actor_id => @story.user.id, :action_type => "Story", :action_id => @story.id)
    end
    
    sharing = params[:share]
    if sharing
      current_user.post_to_twitter(@story, story_url(@story)) unless sharing[:twitter].blank?
      current_user.post_to_facebook(@story, story_url(@story)) unless sharing[:facebook].blank?
    end
    
    # tell their followers (TODO: Background this later)
    @story.user.subscribers.each do |user|
      NotificationsMailer.content_from_following(user, @story.user, @story) if user.send_following_update_emails?
    end
    
    # track analytics across redirect
    flash[:track_story_publish] = @story.id
    
    redirect_to user_path(@story.user)#, :notice => "Your content has been shared!"
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
  
  def crop
    options = params[:story]
    options.merge!({:autosaving => true})
    if @story.update_attributes(options)
      redirect_to edit_story_path(@story)
    else
      render :crop
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
    Activity.where(:action_id => @story.id, :action_type => "Story").destroy_all
    @story.destroy
    redirect_to user_path(current_user)
  end
  
  def autosave
    if params[:story].blank?
      render :json => {:result => "failure", :message => "No story data sent"} and return
    end
    
    # are we updating the external link page?
    if params[:story][:external_link]
      external_page = @story.pages.first
      if external_page.text_media.nil?
        external_page.medias << PageText.new
      end
      link = params[:story][:external_link]
      #metadata = @story.update_via_opengraph(link)
      external_page.text_media.update_attribute(:text, link)
      render :json => {:result => "success"}
      return
    end
    
    params[:story][:tag_list].downcase! if params[:story][:tag_list]
    params[:story][:template_text].slice!(255..10000) if params[:story][:template_text]

    @story.autosaving = true
    if @story.update_attributes(params[:story])
      render :json => {:result => "success"}
    else
      render :json => {:result => "failure", :message => @story.errors.full_messages}
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
  
  def remove_tag_from
    story = Story.find_by_id(params[:id])
    render :text => "" and return if story.nil? || params[:tag].blank?
    story.tag_list.remove(params[:tag])
    story.save
    render :text => ""
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
    
  private
    
  def get_topics
    @topics = Topic.all
  end
  
  def check_sharing_configured
    if current_user
      @twitter_auth = current_user.authentications.find_by_provider("twitter")
      @facebook_auth = current_user.authentications.find_by_provider("facebook")
    end
  end
          
end
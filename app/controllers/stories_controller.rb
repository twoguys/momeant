class StoriesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :find_story, :only => [:preview, :purchase, :show]
  before_filter :get_topics, :only => [:new]
  
  def index
    @stories = Story.all
  end
  
  def library
    @stories = current_user.stories
  end
  
  def new
    @story = Story.new
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
  end
  
  def purchase
    if @story
      if @story.user == current_user
        redirect_to @story, :notice => "You created this story silly, you don't need to purchase it!"
      elsif current_user.stories.include?(@story)
        redirect_to @story, :notice => "You already own this story, silly!"
      elsif @story.free?
        Purchase.create(:cost => @story.price, :story_id => @story.id, :user_id => current_user.id)
        redirect_to @story, :notice => "This story is now in your library."
      else  
        # future purchase logic here
        redirect_to home_path, :alert => "Purchasing non-free stories is not yet ready."
      end
    else
      redirect_to home_path, :alert => "Sorry, that story does not exist."
    end
  end
  
  def show
  end
  
  private
  
    def find_story
      @story = Story.find(params[:id])
    end
    
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
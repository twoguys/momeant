class DiscoveryController < ApplicationController

  def index
    if params[:filter].blank? || params[:filter] == "Featured"
      
      @creators = User.joins(:editorial).order("editorials.created_at DESC")
      @content = Story.joins(:editorial).order("editorials.created_at DESC")
      
    elsif params[:filter] == "Popular"

      @creators = User.select("users.id, users.first_name, users.last_name, users.tagline, users.avatar_file_name, SUM(curations.amount)").
        joins(:rewards => :story).
        where("stories.published" => true).
        order("SUM(curations.amount) DESC").
        group("users.id, users.first_name, users.last_name, users.tagline, users.avatar_file_name")
      @content = Story.
        where(:published => true).
        order("reward_count DESC")
        
    elsif params[:filter] == "Newest"

      @creators = User.
        order("created_at DESC")
      @content = Story.
        where(:published => true).
        order("created_at DESC")

    else
      
      @creators = User.select("users.id, users.first_name, users.last_name, users.tagline, users.avatar_file_name, SUM(curations.amount)").
        joins(:rewards => :story).
        where("stories.category" => params[:filter], "stories.published" => true).
        order("SUM(curations.amount) DESC").
        group("users.id, users.first_name, users.last_name, users.tagline, users.avatar_file_name")
      @content = Story.
        where(:category => params[:filter], :published => true).
        order("reward_count DESC")
      
    end
    
    @creators = @creators.page(params[:creators_page]).per(6)
    @content = @content.page(params[:content_page]).per(6)
  end
  
  def content
    if params[:filter].blank? || params[:filter] == "Featured"
      @content = Story.joins(:editorial).order("editorials.created_at DESC")
    elsif params[:filter] == "Popular"
      @content = Story.
        where(:published => true).
        order("reward_count DESC")  
    elsif params[:filter] == "Newest"
      @content = Story.
        where(:published => true).
        order("created_at DESC")
    else
      @content = Story.
        where(:category => params[:filter], :published => true).
        order("reward_count DESC")
    end
    @content = @content.page(params[:content_page]).per(6)
    render partial: "discovery/content"
  end
  
  def creators
    
  end
end
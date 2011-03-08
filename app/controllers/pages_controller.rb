class PagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_story
  
  def create
    if page = Page.create_or_update_page_with(nil, params, @story)
      render :json => {:result => "success", :id => page.id}
    else
      render :json => {:result => "failure"}
    end
  end
  
  def update
    if Page.create_or_update_page_with(@story.page_at(params[:number]), params, @story)
      Rails.logger.info "UPDATED PAGE: #{@story.page_at(params[:number]).inspect}"
      render :json => {:result => "success"}
    else
      render :json => {:result => "failure", :message => "Unable to create/update page"}
    end
  end
  
  def add_or_update_image
    page = Page.find_by_id(params[:id])
    render :json => {:result => "failure", :message => "Page with id #{params[:id]} does not exist"} and return if page.nil?
    
    Rails.logger.info "DJB #{params.inspect}"
    
    if params[:cell]
      image_media = page.image_at_position(params[:cell])
      options = {:page_id => page.id, :position => params[:cell]}
    else
      image_media = page.image_media
      options = {:page_id => page.id}
    end
    image_media = PageImage.new(options) if image_media.nil?
    image_media.image = params[:image]
    
    if image_media.save
      render :json => {:result => "success", :full => image_media.image.url, :thumbnail => image_media.image.url(:medium)}
    else
      render :json => {:result => "failure", :message => "Unable to save image"}
    end
  end
  
  def destroy
    
  end
  
  private
  
  def find_story
    @story = Story.find_by_id(params[:story_id])
  end
  
end
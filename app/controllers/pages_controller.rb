class PagesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_story
  skip_before_filter :verify_authenticity_token, :only => [:add_or_update_image]
  
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
    
    old_text = nil
    # only for the grid, remove the text for this position + side if it exists (after successful image save)
    if page.is_a?(GridPage) && page.media_at_position_and_side(params[:position], params[:side]).is_a?(PageText)
      old_text = page.media_at_position_and_side(params[:position], params[:side])
    end
    
    image_media = page.medias.where(:type => "PageImage")
    image_media = image_media.where(:position => params[:position]) if params[:position]
    image_media = image_media.where(:side => params[:side]) if params[:side]
    image_media = image_media.first
    
    image_media = PageImage.new(:page_id => page.id, :position => params[:position], :side => params[:side]) if image_media.nil?
    image_media.image = params[:image]
    
    if image_media.save
      old_text.destroy if old_text  
      render :json => {:result => "success", :full => image_media.image.url, :thumbnail => image_media.image.url(:medium)}
    else
      render :json => {:result => "failure", :message => "Unable to save image"}
    end
  end
  
  def destroy
    @page = Page.find_by_id(params[:id])
    render :json => {:result => "failure"} and return if @page.blank?
    
    @page.remove_from_list
    @page.destroy if @page
    render :json => {:result => "success"}
  end
  
  private
  
  def find_story
    @story = Story.find_by_id(params[:story_id])
  end
  
end
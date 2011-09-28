class GalleriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_gallery, :except => [:create, :update_description]
  
  def create
    user = User.find_by_id(params[:user_id])
    return if user.nil?
    
    if user.galleries.create(params[:gallery])
      render :json => {:success => true, :id => user.galleries.last.id}
    else
      render :json => {:success => false}
    end
  end
  
  def update_description
    @gallery = Gallery.find(params[:element_id])
    @gallery.update_attribute(:description, params[:update_value])
    render :text => params[:update_value]
  end
  
  def move_up
    @gallery.move_higher
    redirect_to creations_user_path(current_user)
  end
  
  def move_down
    @gallery.move_lower
    redirect_to creations_user_path(current_user)
  end
  
  private
  
  def find_gallery
    @gallery = Gallery.find(params[:id])
  end
end
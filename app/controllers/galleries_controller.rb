class GalleriesController < ApplicationController
  def create
    user = User.find_by_id(params[:user_id])
    return if user.nil?
    
    if user.galleries.create(params[:gallery])
      render :json => {:success => true, :id => user.galleries.last.id}
    else
      render :json => {:success => false}
    end
  end
end
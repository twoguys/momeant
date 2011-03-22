class Admin::AdvertsController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def index
    @advert = Advert.new
  end
  
  def create
    @advert = Advert.new(params[:advert])
    if @advert.save
      redirect_to admin_adverts_path, :notice => "Advert created"
    else
      render "index"
    end
  end
  
  def destroy
    @advert = Advert.find_by_id(params[:id])
    if @advert
      @advert.destroy
      redirect_to admin_adverts_path, :notice => "Advert removed"
    else
      redirect_to admin_adverts_path, :alert => "Advert not found"
    end
  end
  
  def toggle_enabled
    @advert = Advert.find_by_id(params[:id])
    if @advert
      @advert.update_attribute(:enabled, !@advert.enabled)
      render :json => {:result => "success"}
    else
      render :json => {:result => "failure", :message => "Advert not found"}
    end
  end
  
end
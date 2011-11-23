class Admin::EditorialsController < Admin::BaseController
  
  def new
    @editorial = Editorial.new(:user_id => params[:user])
    render "form"
  end
  
  def create
    @editorial = Editorial.new(params[:editorial])
    if @editorial.save
      redirect_to root_path
    else
      render "form"
    end
  end
end

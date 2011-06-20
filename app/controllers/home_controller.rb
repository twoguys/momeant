class HomeController < ApplicationController
  skip_before_filter :release_lockdown
  before_filter :authenticate_user!, :only => [:subscribe]
  before_filter :get_adverts
  
  def index
    if private_beta? && current_user.nil?
      render "beta" and return
    end
    
    @most_rewarded_stories = Story.published.most_rewarded.page params[:page]
    @nav = "home"
  end
  
  def about
    @nav = "about"
  end
  
  def apply
    redirect_to invite_path unless request.post?
    InvitationsMailer.creator_application(params[:name],params[:email],params[:about],current_user).deliver
    render :json => {:result => "success"} and return
  end
end
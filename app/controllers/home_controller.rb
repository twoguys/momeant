class HomeController < ApplicationController
  skip_before_filter :release_lockdown
  before_filter :authenticate_user!, :except => [:index]
  before_filter :get_adverts
  
  def index
    if current_user.nil?
      render "landing", :layout => "landing" and return
    end
    
    @nav = "home"
    @user = current_user
    @creators = current_user.given_rewards.for_content.group_by {|r| r.recipient}
    render "users/show"
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
class HomeController < ApplicationController
  skip_before_filter :release_lockdown
  before_filter :authenticate_user!, :only => [:subscribe]
  
  def index
    if private_beta? && current_user.nil?
      render "beta" and return
    end
    
    @most_rewarded_stories = Story.published.most_rewarded.page params[:page]
  end
  
  def apply
    redirect_to invite_path unless request.post?
    InvitationsMailer.creator_application(params[:name],params[:email],params[:about]).deliver
    return :json => {:result => "success"}
  end
end
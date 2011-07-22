class HomeController < ApplicationController
  skip_before_filter :release_lockdown
  before_filter :authenticate_user!, :only => [:subscribe, :following]
  before_filter :get_adverts
  
  def index
    if private_beta? && current_user.nil?
      render "beta" and return
    end
    
    if current_user
      load_following_rewards
      @nav = "home"
      @sidenav = "following"
    else
      @most_rewarded_stories = Story.published.most_rewarded.page params[:page]
      @nav = "home"
      @sidenav = "global"
    end
  end
  
  def global
    @most_rewarded_stories = Story.published.most_rewarded.page params[:page]
    @nav = "home"
    @sidenav = "global"
    render "index"
  end
  
  def following
    load_following_rewards
    @nav = "home"
    @sidenav = "following"
    render "index"
  end
  
  def about
    @nav = "about"
  end
  
  def apply
    redirect_to invite_path unless request.post?
    InvitationsMailer.creator_application(params[:name],params[:email],params[:about],current_user).deliver
    render :json => {:result => "success"} and return
  end
  
  private
  
    def load_following_rewards
      @rewards = []
      return if current_user.subscribed_to.count == 0

      following_ids = current_user.subscribed_to.map { |user| user.id }.join(",")
      @rewards = Reward.select("DISTINCT ON (story_id) curations.*").where("user_id IN (#{following_ids})").page params[:page]

      # add duplicate reward count to each piece of content
      @rewards.each do |reward|
        other_rewards = Reward.where(:story_id => reward.story_id).where("user_id IN (#{following_ids})").where("id != #{reward.id}")
        if other_rewards.size > 0
          reward[:other_rewards] = other_rewards
        end
      end
    end
end
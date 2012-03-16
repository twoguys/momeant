class SupportController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @nav = "support"
    @creators = current_user.rewarded_creators
    @content = []
    return if @creators.empty?
    @content = Story.published.newest_first.where("user_id IN (#{@creators.map(&:id).join(",")})")
  end
  
  def filter #ajax
    @content = User.find(params[:id]).created_stories.published.newest_first
    render :partial => "support/content", :collection => @content, :as => :content
  end
end
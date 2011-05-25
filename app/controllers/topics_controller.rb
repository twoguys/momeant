class TopicsController < ApplicationController
  
  def show
    @topic = Topic.where("UPPER(name) = ?", params[:name].upcase).first
    redirect_to root_path, :notice => "Sorry, that topic doesn't exist" if @topic.nil?
    @hide_rewards = true
    @hide_momeant = true
  end
  
end
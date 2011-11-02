class SharingController < ApplicationController
  before_filter :authenticate_user!
  
  def twitter
    current_user.post_to_twitter(@reward, story_url(@story, :impacted_by => @reward.id))
  end
  
  def facebook
    current_user.post_to_facebook(@reward, story_url(@story, :impacted_by => @reward.id))
  end
  
  def twitter_form
    @reward = Reward.find_by_id(params[:reward_id]) if params[:reward_id]
    render :partial => "rewards/modal/twitter_sharing"
  end
  
  def facebook_form
    @reward = Reward.find_by_id(params[:reward_id]) if params[:reward_id]
    render :partial => "rewards/modal/facebook_sharing"
  end
end
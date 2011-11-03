class SharingController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_reward
  
  def twitter
    comment = params[:comment]
    current_user.post_to_twitter(@reward, story_url(@reward.story, :impacted_by => @reward.id), comment)
    render :json => {:success => true}
  end
  
  def facebook
    comment = params[:comment]
    current_user.post_to_facebook(@reward, story_url(@reward.story, :impacted_by => @reward.id), comment)
    render :json => {:success => true}
  end
  
  def twitter_form
    render :partial => "rewards/modal/twitter_sharing"
  end
  
  def facebook_form
    render :partial => "rewards/modal/facebook_sharing"
  end
  
  private
  
  def find_reward
    @reward = Reward.find_by_id(params[:reward_id]) if params[:reward_id]
  end
end
class SharingController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_reward
  
  def twitter
    comment = params[:comment]
    current_user.post_to_twitter(@reward, @reward.content_url_with_impacted_by, comment)
    render :partial => "rewards/modal/after_tweeting"
  end
  
  def facebook
    comment = params[:comment]
    current_user.post_to_facebook(@reward, @reward.content_url_with_impacted_by, comment)
    render :partial => "rewards/modal/after_facebooking"
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
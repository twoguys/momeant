class Admin::DashboardController < Admin::BaseController

  def index
    @users = User.count
    @creators = Creator.count
    @signups_per_day = User.per_day(1.month)
    
    @content = Story.published.count
    @content_per_day = Story.published.per_day(1.month)
    
    @follows = Subscription.count
    @follows_per_day = Subscription.per_day(1.month)
    
    @rewards = Reward.sum(:amount)
    @rewards_per_day = Reward.per_day(1.month)
    
    @revenue = Reward.where(paid_for: true).sum(:amount) * 0.2
    @revenue_per_day = Transaction.where(type: "AmazonPayment").per_day(1.month)
  end
  
  def change_user_to
    User.find(params[:id]).update_attribute(:type, params[:type])
    render :text => ""
  end
  
end
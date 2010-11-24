class PayPeriodsController < InheritedResources::Base
  before_filter :authenticate_user!
  load_and_authorize_resource
  
  def create
    @pay_period = PayPeriod.create(:user_id => current_user.id, :end => Time.now)
    @pay_period.create_line_items
    redirect_to @pay_period
  end
end
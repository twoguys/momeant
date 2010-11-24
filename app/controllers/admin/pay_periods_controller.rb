class Admin::PayPeriodsController < Admin::BaseController
  
  def index
    @pay_periods = PayPeriod.all
  end
  
  def create
    @pay_period = PayPeriod.create(:user_id => current_user.id, :end => Time.now)
    @pay_period.create_line_items
    redirect_to admin_pay_period_path(@pay_period)
  end
  
  def show
    @pay_period = PayPeriod.find(params[:id])
  end
end
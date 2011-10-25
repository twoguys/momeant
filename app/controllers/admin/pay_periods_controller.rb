class Admin::PayPeriodsController < Admin::BaseController
  
  def index
    @pay_periods = PayPeriod.all
    @requested_cashouts = Cashout.requested
  end
  
  def create
    @pay_period = PayPeriod.create(:user_id => current_user.id, :end => Time.now)
    @pay_period.reload
    Cashout.requested.update_all(:pay_period_id => @pay_period.id, :state => "paid")
    redirect_to admin_pay_periods_path, :notice => "Payments have been sent to the necessary creators."
  end
  
  def show
    @pay_period = PayPeriod.find(params[:id])
    respond_to do |format|
      format.html
      format.csv do
        send_data @pay_period.to_csv,
          :type => 'text/csv; charset=iso-8859-1;',
          :disposition => "attachment; filename=pay-period-#{@pay_period.print_date.gsub('/','-')}.csv"
      end
    end
  end
  
  def mark_paid
    @pay_period = PayPeriod.find(params[:id])
    @pay_period.pay!
    redirect_to admin_pay_period_path(@pay_period), :notice => "Payments have been entered for each line item."
  end
end
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
    respond_to do |format|
      format.html
      format.csv do
        send_data @pay_period.to_csv,
          :type => 'text/csv; charset=iso-8859-1;',
          :disposition => "attachment; filename=pay-period-#{@pay_period.print_date.gsub('/','-')}"
      end
    end
  end
  
  def mark_paid
    @pay_period = PayPeriod.find(params[:id])
    @pay_period.mark_as_paid
    redirect_to admin_pay_period_path(@pay_period), :notice => "Payments have been entered for each line item."
  end
end
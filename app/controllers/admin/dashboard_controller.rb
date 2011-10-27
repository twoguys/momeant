class Admin::DashboardController < Admin::BaseController
  def index
    @payments = AmazonPayment.paid
    @cashouts_paid = Cashout.paid
    @cashouts_requested = Cashout.requested
    
    if params[:after].present?
      @payments = @payments.where("created_at > '#{params[:after]}'")
      @cashouts_paid = @cashouts_paid.where("created_at > '#{params[:after]}'")
      @cashouts_requested = @cashouts_requested.where("created_at > '#{params[:after]}'")
    end
    if params[:before].present?
      @payments = @payments.where("created_at < '#{params[:before]}'")
      @cashouts_paid = @cashouts_paid.where("created_at < '#{params[:before]}'")
      @cashouts_requested = @cashouts_requested.where("created_at < '#{params[:before]}'")
    end
  end
end
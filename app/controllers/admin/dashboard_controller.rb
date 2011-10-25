class Admin::DashboardController < Admin::BaseController
  def index
    @payments = AmazonPayment.paid
    @cashouts_paid = Cashout.paid
    @cashouts_requested = Cashout.requested
  end
end
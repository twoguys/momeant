class AmazonPaymentsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @payment = AmazonPayment.new(:amount => 10)
    @past_payments = current_user.amazon_payments
    @nav = "coins"
    @nosidebar = true
  end
  
  def create
    @payment = current_user.amazon_payments.create(params[:amazon_payment])
    redirect_to @payment.amazon_cbui_url(accept_coins_url)
  end
  
  def accept
    @payment = AmazonPayment.find(params[:callerReference])
    @payment.accept!
    @payment.update_attribute(:amazon_token, params[:tokenID])
    
    # post to Amazon to charge it
    @payment.settle_with_amazon
    @payment.mark_as_paid!
    flash[:track_coin_purchase] = @payment.amount
    redirect_to root_path, :notice => "THANK YOU! #{@payment.coins} coins were added to your account."
  end
  
end
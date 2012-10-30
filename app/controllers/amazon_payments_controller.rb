require 'amazon/fps/fpspayments'

class AmazonPaymentsController < ApplicationController
  before_filter :authenticate_user!, except: [:update_status]
  
  def index
    @payment = AmazonPayment.new(:amount => 10)
    @past_payments = current_user.amazon_payments
    @nav = "coins"
  end
  
  def create
    @payment = current_user.amazon_payments.create(params[:amazon_payment])
    redirect_to @payment.amazon_cbui_url(accept_payment_url)
  end
  
  def accept
    @payment = AmazonPayment.find(params[:callerReference])
    @payment.accept!
    @payment.update_attribute(:amazon_token, params[:tokenID])
    
    # post to Amazon to charge it
    @payment.settle_with_amazon
    @payment.mark_as_paid!
    flash[:track_rewards_payment] = @payment.amount
    redirect_to fund_rewards_path, :notice => "Thank you for supporting creators! You're the best."
  end
  
  def start_postpaid
    redirect_to AmazonPayment.amazon_postpaid_cbui_url(current_user.id, accept_amazon_postpaid_url)
  end
  
  def accept_postpaid
    render text: params[:errorMessage] and return if params[:errorMessage].present?
    #render text: "Invalid Signature" and return unless valid_signature?(request, rebuild_query_string(params))
    current_user.update_attributes(
      amazon_status_code: params[:status],
      amazon_credit_instrument_id: params[:creditInstrumentID],
      amazon_credit_sender_token_id: params[:creditSenderTokenID],
      amazon_settlement_token_id: params[:settlementTokenID],
      needs_to_reauthorize_amazon_postpaid: false
    )
    
    # TODO: check the status code for bad stuff
    
    current_user.given_rewards.pledged.each do |reward|
      current_user.attribute_debt(reward)
    end
    current_user.settle_debt if current_user.surpassed_credit_limit?
    
    redirect_to fund_rewards_path
  end
  
  def update_status
    Rails.logger.info "IPN NOTIFICATION"
    Rails.logger.info params.inspect
    payment = AmazonPayment.where(amazon_transaction_id: params[:transactionId]).first
    payment.update_status(params) 
    head :ok
  end
  
  private
  
  def valid_signature?(request, parameter_string)
    url = "#{request.protocol}#{request.host_with_port}#{request.path}"
    endpoint = Amazon::FPS::Payments.validate_signature_url(url, parameter_string)
    response = RestClient.get(endpoint)
    # check for VerificationStatus in response to be "Success"
    # TODO: figure out why the RestClient request is getting an HTTP 400
  end
  
  def rebuild_query_string(parameters)
    query = ""
    query_string = parameters.select {|k,v| not %w[action controller source].include?(k)}
    unless query_string.empty?
      query_params = query_string.collect {|k,v| "#{k}=#{v}"}
      query << query_params.join("&")
    end
    return query
  end
  
end

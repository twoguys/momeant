require 'amazon/fps/fpspayments'

class AmazonPayment < Transaction
  include ActionView::Helpers::NumberHelper
  
  validates :amount, :presence => true
  
  before_create :assign_token
  
  POSTPAID_CREDIT_LIMIT = 100
  
  def fees
    if self.amount >= 10
      self.amount * 0.029 + 0.3
    else
      self.amount * 0.05 + 0.05
    end
  end
  
  def momeant_cut
    self.amount * 0.2
  end
  
  def momeant_revenue
    self.momeant_cut - self.fees
  end
  
  def amazon_cbui_url(return_url)
    Amazon::FPS::Payments.get_cobranded_url(self.amount, "#{number_to_currency self.amount} in pledged rewards", self.id, return_url)
  end
  
  def self.amazon_postpaid_cbui_url(user_id, return_url)
    Amazon::FPS::Payments.get_postpaid_cobranded_url(user_id, POSTPAID_CREDIT_LIMIT, return_url)
  end
  
  def send_debt_to_amazon!
    url = Amazon::FPS::Payments.get_pay_url(self.amount, self.token, self.payer.amazon_credit_sender_token_id)
    
    Rails.logger.info "AMAZON PAY RESPONSE:"
    begin
      response = RestClient.get url
    rescue Exception => e
      Rails.logger.info e.inspect
      if e.inspect.to_s.include?("InsufficientBalance")
        Rails.logger.info "INSUFFICIENT BALANCE"
        self.payer.update_attribute(:needs_to_reauthorize_amazon_postpaid, true)
        raise Exceptions::AmazonPayments::InsufficientBalanceException
      end
    end
    Rails.logger.info response
    
    doc = Nokogiri::XML(response)
    transaction_id = doc.search("TransactionId").first.content
    transaction_status = doc.search("TransactionStatus").first.content
    
    self.update_attributes(amazon_transaction_id: transaction_id, state: transaction_status.downcase)
    handle_postpaid_settlement_errors(state) unless ["pending", "success"].include?(state)
  end
  
  def settle_postpaid_debt!
    url = Amazon::FPS::Payments.get_postpaid_settle_url(
      self.amount,
      self.token,
      self.payer.amazon_credit_instrument_id,
      self.payer.amazon_settlement_token_id
    )
    
    Rails.logger.info "AMAZON SETTLEDEBT RESPONSE:"
    begin
      response = RestClient.get url
    rescue Exception => e
      Rails.logger.info e.inspect
      raise
    end
    Rails.logger.info response
    
    doc = Nokogiri::XML(response)
    transaction_id = doc.search("TransactionId").first.content
    transaction_status = doc.search("TransactionStatus").first.content.downcase

    self.update_attributes(amazon_transaction_id: transaction_id, state: transaction_status.downcase)
    handle_postpaid_settlement_errors(state) unless ["pending", "success"].include?(state)
    mark_rewards_as_funded if state == "success"
  end
  
  def handle_postpaid_settlement_errors(state)
    Rails.logger.error "ERROR SETTLING DEBT: #{state}"
    payer.update_attribute(:needs_to_reauthorize_amazon_postpaid, true)
    NotificationsMailer.payment_error(payer).deliver
  end
  
  def update_status(params) # via Amazon IPN notifications
    
    # TODO: validate the signature so people can't spoof it
    
    previous_state = state
    new_state = translate_amazon_ipn_status(params[:status])

    self.update_attribute(:state, new_state)

    if new_state == "success" && used_for == "SettleDebt"
      mark_rewards_as_funded
    end
      
    if new_state == "failure" && previous_state != "failure"
      payer.update_attribute(:needs_to_reauthorize_amazon_postpaid, true)
      NotificationsMailer.payment_error(payer).deliver
    end
  end
  
  private
  
  def mark_rewards_as_funded
    Reward.where(amazon_settlement_id: self.id).update_all(paid_for: true)
  end
  
  def translate_amazon_ipn_status(status)
    case status
    when "PS"
      "success"
    when "PF"
      "failure"
    when "PI"
      "pending"
    when "PR"
      "success"
    else
      status
    end
  end
  
  def assign_token
    self.token = SecureRandom.hex(30)
  end
end
require 'amazon/fps/fpspayments'

class AmazonPayment < Transaction
  include ActionView::Helpers::NumberHelper
  
  validates :amount, :presence => true
  
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
    url = Amazon::FPS::Payments.get_pay_url(self.amount, self.id, self.payer.amazon_credit_sender_token_id)
    
    begin
      response = RestClient.get url
    rescue Exception => e
      if e.inspect.to_s.include?("InsufficientBalance")
        self.payer.update_attribute(:needs_to_reauthorize_amazon_postpaid, true)
        raise Exceptions::AmazonPayments::InsufficientBalanceException
      end
    end
      
    doc = Nokogiri::XML(response)
    transaction_id = doc.search("TransactionId").first.content
    transaction_status = doc.search("TransactionStatus").first.content
    self.update_attributes(amazon_transaction_id: transaction_id, state: transaction_status.downcase)
  end
  
  def settle_postpaid_debt!
    Rails.logger.info "SETTLING DEBT WITH AMAZON #{self.amount}"
    url = Amazon::FPS::Payments.get_postpaid_settle_url(
      self.amount,
      self.id,
      self.payer.amazon_credit_instrument_id,
      self.payer.amazon_settlement_token_id
    )
    response = RestClient.get url
    doc = Nokogiri::XML(response)
    
    transaction_id = doc.search("TransactionId").first.content
    transaction_status = doc.search("TransactionStatus").first.content
    self.update_attributes(amazon_transaction_id: transaction_id, state: transaction_status.downcase)
    
    handle_postpaid_settlement_errors(self.state) unless ["pending", "success"].include?(self.state)

    return ["pending", "success"].include?(self.state)
  end
  
  def handle_postpaid_settlement_errors(state)
    Rails.logger.error "ERROR SETTLING DEBT: #{state}"
    # TODO: send an email to the user?
  end
end
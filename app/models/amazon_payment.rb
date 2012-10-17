require 'amazon/fps/fpspayments'

class AmazonPayment < Transaction
  include ActionView::Helpers::NumberHelper
  
  validates :amount, :presence => true
  
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
    Amazon::FPS::Payments.get_postpaid_cobranded_url(user_id, return_url)
  end
  
  def settle_with_amazon
    url = Amazon::FPS::Payments.get_pay_url(self.amount, self.amazon_token)
    response = RestClient.get url
    doc = Nokogiri::XML(response)
    
    transaction_id = doc.search("TransactionId").first.content
    self.update_attribute(:amazon_transaction_id, transaction_id)
    self.payer.pay_for_pledged_rewards!(self.id)
    
    Activity.create(:actor_id => self.payer_id, :action_type => "AmazonPayment", :action_id => self.id)
    if self.payer.amazon_payments.paid.count == 1
      Activity.create(:actor_id => self.payer_id, :action_type => "Badge", :action_id => 2)
    end
  end
end
require 'amazon/fps/fpspayments'

class AmazonPayment < Transaction
  belongs_to :payee, :class_name => "User"
  
  validates :amount, :presence => true
  
  def coins
    case self.amount
    when 5
      25
    when 10
      70
    when 20
      160
    when 100
      900
    end
  end
  
  def coin_string
    "#{self.coins} reward coins"
  end
  
  def fees
    case self.amount
    when 5
      0.3
    when 10
      0.59
    when 20
      0.88
    when 100
      3.20
    end
  end
  
  def momeant_cut
    case self.amount
    when 5
      2.5
    when 10
      3
    when 20
      4
    when 100
      10
    end
  end
  
  def momeant_revenue
    self.momeant_cut - self.fees
  end
  
  def amazon_cbui_url(return_url)
    Amazon::FPS::Payments.get_cobranded_url(self.amount, "#{self.coins} reward coins", self.id, return_url)
  end
  
  def settle_with_amazon
    url = Amazon::FPS::Payments.get_pay_url(self.amount, self.amazon_token)
    response = RestClient.get url
    doc = Nokogiri::XML(response)
    
    transaction_id = doc.search("TransactionId").first.content
    self.update_attribute(:amazon_transaction_id, transaction_id)
    self.payer.increment!(:coins, self.coins)
  end
end
class Deposit < Transaction
  belongs_to :payee, :class_name => "User"
  
  validates_presence_of :credit_card_number, :credit_card_month, :credit_card_year, :credit_card_cvv, :credits,
                        :first_name, :last_name, :street1, :city, :state, :zipcode,
                        :unless => :skip_credit_card_validation
  
  attr_accessor :credit_card_number, :credit_card_month, :credit_card_year, :credit_card_cvv, :credits,
                :first_name, :last_name, :street1, :street2, :city, :state, :zipcode, :skip_credit_card_validation, :credit_card_id
                
  def set_amount_based_on_credits
    case self.credits
    when "500"
      self.amount = 5.00
    when "1000"
      self.amount = 9.00
    when "2000"
      self.amount = 17.00
    else
      return false
    end
    return true
  end
end
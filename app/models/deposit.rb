class Deposit < Transaction
  belongs_to :payee, :class_name => "User"
  
  attr_accessor :credit_card_number, :credit_card_month, :credit_card_year, :credit_card_cvv
end
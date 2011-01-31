class DepositsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @deposit = Deposit.new(:credits => 500)
  end
  
  def create
    @deposit = Deposit.new(params[:deposit])
    
    existing_card = @deposit.skip_credit_card_validation = true unless @deposit.credit_card_number.present?
    
    if !@deposit.valid?
      render "index" and return
    end
    
    Rails.logger.info "Deposit valid"
    
    if !@deposit.set_amount_based_on_credits
      flash[:alert] = "Please choose a credit package"
      render "index" and return
    end
    
    Rails.logger.info "Amount valid"
    
    if existing_card
      card = CreditCard.find_by_id(@deposit.credit_card_id)
      result = charge_existing_credit_card(card.braintree_token, @deposit.amount)

      Rails.logger.info "Using existing card #{card.last_four_digits}"
    else  
      result = charge_new_credit_card(@deposit)
      
      Rails.logger.info "charging new card"
    end
    
    if !result.success?
      Rails.logger.error "[Momeant] Braintree failure, but no errors... #{result.inspect}" if result.errors.size == 0
      result.errors.each do |error|
        Rails.logger.info "[Momeant] Braintree transaction error: #{error.code} - #{error.message}"
        @deposit.errors.add(:base, error.message)
      end
      render "index" and return
    end

    Rails.logger.info "Successful BT result"
    
    if !existing_card
      new_credit_card = CreditCard.create(
        :user_id => current_user.id,
        :last_four_digits => @deposit.credit_card_number[-4..-1],
        :braintree_token => result.transaction.credit_card_details.token
      )
      if !new_credit_card.save
        Rails.logger.error "[Momeant] Unable to create new credit card: #{new_credit_card.inspect}"
      end
    end
    
    @deposit.braintree_order_id = result.transaction.id
    @deposit.payer = current_user
    if !@deposit.save
      Rails.logger.error "[Momeant] Unable to create new deposit: #{deposit.braintree_order_id}, #{current_user.name}, #{deposit.amount}"
    end
    
    current_credits = current_user.credits || 0
    current_user.update_attribute(:credits, current_credits + @deposit.credits.to_i)
    
    redirect_to credits_path, :notice => "#{@deposit.credits} credits were just added to your account!"
  end
  
  private
  
  def charge_new_credit_card(deposit)
    Braintree::Transaction.sale(
      :amount => deposit.amount,
      :customer => {
        :id => current_user.id,
        :first_name => deposit.first_name,
        :last_name => deposit.last_name,
        :email => current_user.email
      },
      :credit_card => {
        :number => deposit.credit_card_number,
        :expiration_date => "#{deposit.credit_card_month}/#{deposit.credit_card_year}",
        :cvv => deposit.credit_card_cvv
      },
      :billing => {
        :street_address => deposit.street1,
        :locality => deposit.city,
        :region => deposit.state,
        :postal_code => deposit.zipcode
      },
      :options => {
        :store_in_vault => true,
        :add_billing_address_to_payment_method => true,
        :submit_for_settlement => true
      }
    )
  end
  
  def charge_existing_credit_card(credit_card_token, amount)
    Braintree::CreditCard.sale(credit_card_token, :amount => amount)
  end
end

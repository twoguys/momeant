require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "A user can deposit credits into their account" do

  in_order_to "purchase Momeant content"
  as_a "user"
  i_want_to "pay money for Momeant credits"
  
  Scenario "A user enters a valid credit card" do
    # given_a(:email_confirmed_user)
    # given_im_signed_in_as(:email_confirmed_user)
    # 
    # when_i_visit_page(:credits)
    # 
    # And "I choose how many credits to purchase" do
    #   fill_in "deposit_amount", :with => "10.00"
    # end
    # 
    # And "I fill in my credit card information" do
    #   card = Factory.build(:credit_card)
    #   fill_in "deposit_credit_card_number", :with => card.number
    #   select card.month.to_s, :from => "deposit_credit_card_month"
    #   select card.year.to_s, :from => "deposit_credit_card_year"
    #   fill_in "deposit_credit_card_cvv", :with => card.cvv
    # end
    # 
    # And "I fill in my personal information" do
    #   fill_in "user_first_name", :with => 
    # end
  end
  
  Scenario "A user enters an invalid credit card"
  
end
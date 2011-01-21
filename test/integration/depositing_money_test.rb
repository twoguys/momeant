require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "A user can deposit credits into their account" do

  in_order_to "purchase Momeant content"
  as_a "user"
  i_want_to "pay money for Momeant credits"
  
  Scenario "A user enters a valid credit card" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    
    when_i_visit_page(:credits)
    
    
  end
  
  Scenario "A user enters an invalid credit card"
  
end
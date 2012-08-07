require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "Admins can create a pay period to pay requested creator cashouts" do

  in_order_to "pay out requested cashouts"
  as_a "admin"
  i_want_to "create a new pay period that pays the necessary creators"
  
  Scenario "An admin can see how much in unpaid cashouts there are" do
    given_a :admin
    given_im_signed_in_as(:admin)
    
    when_i_visit_page(:admin_pay_periods)
  end
  
end
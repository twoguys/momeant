require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "A user can deposit credits into their account", :testcase_class => FullStackTest do

  in_order_to "purchase Momeant content"
  as_a "user"
  i_want_to "pay money for Momeant credits"
  
  Scenario "A user does not have a credit card stored with Braintree yet" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    
    when_i_visit_page(:credits)
    
    And "I choose how many credits to purchase" do
      @old_credits = @email_confirmed_user.credits
      choose "deposit_credits_1000"
    end
    
    And "I fill in my credit card information" do
      fill_in "deposit_credit_card_number", :with => "4111111111111111"
      select "12", :from => "deposit_credit_card_month"
      select (Date.today.year + 5).to_s, :from => "deposit_credit_card_year"
      fill_in "deposit_credit_card_cvv", :with => "123"
    end
    
    And "I fill in my personal information" do
      fill_in "deposit_first_name", :with => "John"
      fill_in "deposit_last_name", :with => "Doe"
      fill_in "deposit_street1", :with => "123 Road St"
      fill_in "deposit_city", :with => "Pensacola"
      select "Florida", :for => "user_state"
      fill_in "deposit_zipcode", :with => "32563"
    end
    
    And "I click the purchase credits button" do
      click_button "Purchase credits"
    end
    
    Then "I should have a credit card summary (last 4 digits) assigned to my Momeant account and linking to a Braintree vault card" do
      card = @email_confirmed_user.reload.credit_cards.first
      assert card.present?
      assert_equal "1111", card.last_four_digits
      assert card.braintree_token.present?
    end
    
    And "I should have the proper number of credits added to my account" do
      assert_equal @old_credits + 1000, @email_confirmed_user.credits
    end
    
    And "there should be a Deposit recorded with the user, amount, and Braintree order id" do
      deposit = Deposit.last
      assert_equal @email_confirmed_user, deposit.payer
      assert_equal 9.0, deposit.amount
      assert deposit.braintree_order_id.present?
    end
  end
  
  Scenario "A user reuses a previously-used credit card stored with Braintree" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    Given "A credit card for this user" do
      Factory :credit_card, :user => @email_confirmed_user, :braintree_token => "btds"
    end
    
    when_i_visit_page(:credits)
  
    And "I choose how many credits to purchase" do
      @old_credits = @email_confirmed_user.credits
      choose "deposit_credits_1000"
    end
    
    And "I choose to use my existing credit card (by seeing the last four digits)" do
      card = @email_confirmed_user.credit_cards.first
      select "Ending in #{card.last_four_digits}"
    end
    
    And "I click the purchse credits button" do
      click_button "Purchase credits"
    end
    
    And "I should have the proper number of credits added to my account" do
      @email_confirmed_user.reload
      assert_equal @old_credits + 1000, @email_confirmed_user.credits
    end
    
    And "there should be a Deposit recorded with the user, amount, and Braintree order id" do
      deposit = Deposit.last
      assert_equal @email_confirmed_user, deposit.payer
      assert_equal 9.0, deposit.amount
      assert deposit.braintree_order_id.present?
    end
  end
  
  Scenario "A user decides to enter a second credit card" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    Given "A credit card for this user" do
      Factory :credit_card, :user => @email_confirmed_user
    end
    
    when_i_visit_page(:credits)
  
    And "I choose how many credits to purchase" do
      @old_credits = @email_confirmed_user.credits
      choose "deposit_credits_1000"
    end
    
    And "I should be given the option to enter a different credit card (and billing info)" do
      click_link "OR use a new credit card"
    end
    
    And "I fill in my credit card information" do
      fill_in "deposit_credit_card_number", :with => "4111111111111111"
      select "12", :from => "deposit_credit_card_month"
      select (Date.today.year + 5).to_s, :from => "deposit_credit_card_year"
      fill_in "deposit_credit_card_cvv", :with => "123"
    end
    
    And "I fill in my personal information" do
      fill_in "deposit_first_name", :with => "John"
      fill_in "deposit_last_name", :with => "Doe"
      fill_in "deposit_street1", :with => "123 Road St"
      fill_in "deposit_city", :with => "Pensacola"
      select "Florida", :for => "user_state"
      fill_in "deposit_zipcode", :with => "32563"
    end
    
    And "I click the purchase credits button" do
      click_button "Purchase credits"
    end
    
    Then "I should have a credit card summary (last 4 digits) assigned to my Momeant account and linking to a Braintree vault card" do
      @email_confirmed_user.reload
      card = @email_confirmed_user.credit_cards.last
      assert card.present?
      assert_equal "1111", card.last_four_digits
      assert card.braintree_token.present?
    end
    
    And "I should have the proper number of credits added to my account" do
      assert_equal @old_credits + 1000, @email_confirmed_user.credits
    end
    
    And "there should be a Deposit recorded with the user, amount, and Braintree order id" do
      deposit = Deposit.last
      assert_equal @email_confirmed_user, deposit.payer
      assert_equal 9.0, deposit.amount
      assert deposit.braintree_order_id.present?
    end
  end
  
  Scenario "A user enters a CVV code that does not match their card" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    
    when_i_visit_page(:credits)
    
    And "I choose how many credits to purchase" do
      @old_credits = @email_confirmed_user.credits
      choose "deposit_credits_1000"
    end
    
    And "I fill in my credit card information" do
      fill_in "deposit_credit_card_number", :with => "4111111111111111"
      select "12", :from => "deposit_credit_card_month"
      select (Date.today.year + 5).to_s, :from => "deposit_credit_card_year"
      fill_in "deposit_credit_card_cvv", :with => "200"
    end
    
    And "I fill in my personal information" do
      fill_in "deposit_first_name", :with => "John"
      fill_in "deposit_last_name", :with => "Doe"
      fill_in "deposit_street1", :with => "123 Road St"
      fill_in "deposit_city", :with => "Pensacola"
      select "Florida", :for => "user_state"
      fill_in "deposit_zipcode", :with => "32563"
    end
    
    And "I click the purchase credits button" do
      click_button "Purchase credits"
    end
    
    then_i_should_see_error("Invalid CVV code")
  end
  
  Scenario "A user enters a zip code that does not match their card" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    
    when_i_visit_page(:credits)
    
    And "I choose how many credits to purchase" do
      @old_credits = @email_confirmed_user.credits
      choose "deposit_credits_1000"
    end
    
    And "I fill in my credit card information" do
      fill_in "deposit_credit_card_number", :with => "4111111111111111"
      select "12", :from => "deposit_credit_card_month"
      select (Date.today.year + 5).to_s, :from => "deposit_credit_card_year"
      fill_in "deposit_credit_card_cvv", :with => "123"
    end
    
    And "I fill in my personal information" do
      fill_in "deposit_first_name", :with => "John"
      fill_in "deposit_last_name", :with => "Doe"
      fill_in "deposit_street1", :with => "123 Road St"
      fill_in "deposit_city", :with => "Pensacola"
      select "Florida", :for => "user_state"
      fill_in "deposit_zipcode", :with => "20000"
    end
    
    And "I click the purchase credits button" do
      click_button "Purchase credits"
    end
    
    then_i_should_see_error("Invalid postal code")
  end
  
end
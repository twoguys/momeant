require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "Momeant can pay creators for the sales they've made" do

  in_order_to "pay creators for what they've sold and see a history"
  as_a "admin"
  i_want_to "end a pay period, see who needs to be paid, and mark them as paid once I've sent money"
  
  Scenario "An admin ends a pay period" do
    given_a(:admin)
    given_im_signed_in_as(:admin)
    given_a(:purchase)
    given_a(:email_confirmed_user)
    Given "Another purchase for the same story by a different user" do
      @second_purchase = Purchase.create(:amount => @purchase.story.price,
                                         :story_id => @purchase.story.id,
                                         :payer_id => @email_confirmed_user.id,
                                         :payee_id => @purchase.story.user_id)
    end
    Given "A purchase for a different creator's story" do
      @purchase2 = Factory(:purchase)
    end
    
    when_i_visit_page(:admin_pay_periods)
    
    When "I click end current pay period" do
      click_button("End current pay period")
    end
    
    Then "I should be on the new pay period page" do
      assert_equal admin_pay_period_path(PayPeriod.last), current_path
    end
    
    And "I should see a pay period line item for each creator that needs to be paid" do
      line_item_amount = @purchase.amount + @second_purchase.amount
      line_item2_amount = @purchase2.amount
      assert page.has_content? number_to_currency(line_item_amount)
      assert page.has_content? number_to_currency(line_item2_amount)
    end
    
    And "A pay period exists with a line item for each creator" do
      pay_period = PayPeriod.last
      assert_equal 2, pay_period.line_items.count
    end
    
    And "The Creator should have a pay period line item associated with each sale" do
      @purchase.payee.sales do |sale|
        assert !sale.line_item.nil?
      end
    end
  end
  
  Scenario "An admin views a CSV of the line items for a previous pay period" do
    given_a(:admin)
    given_im_signed_in_as(:admin)
    given_a(:pay_period)
    
    when_i_visit_page(:admin_pay_periods)
    
    And "I click the download csv link" do
      click_link "Download CSV"
    end
    
    Then "I should get back a CSV file with a header and then each line having a payment's amount and payee name" do
      i = 0
      line_items = @pay_period.line_items
      FasterCSV.parse(page.body, :headers => true) do |row|
        assert_equal number_to_currency(line_items[i].amount), row[0].strip
        assert_equal line_items[i].payee.name, row[1].strip
        i += 1
      end
    end
  end
  
  Scenario "An admin marks a pay period as paid (with no previous pay period)" do
    given_a(:admin)
    given_im_signed_in_as(:admin)
    given_a(:pay_period)
    given_a(:purchase)
    
    Given "The pay period line items were created" do
      @pay_period.create_line_items
    end
    
    When "I visit the pay period page" do
      visit admin_pay_period_path(@pay_period)
    end
    
    And "I click the mark as paid button" do
      click_button "Mark as paid"
    end
    
    Then "there should be payment transactions stored for each creator requiring payment in the pay period" do
      @pay_period.line_items.each do |line_item|
        assert_equal line_item.amount, line_item.payee.payments.last.amount
      end
    end
    
    And "each Creator that was paid should have a balance of 0" do
      @pay_period.line_items.each do |line_item|
        assert_equal 0, line_item.payee.balance
      end
    end
    
    And "the pay period should be marked as paid" do
      assert PayPeriod.last.paid?
    end
    
    And "all purchases should have associated line items" do
      assert_equal 0, Purchase.where(:pay_period_line_item_id => nil).count
    end
  end
  
  Scenario "An admin marks a pay period as paid (with an existing previous pay period)" do
    given_a(:email_confirmed_user)
    given_a(:admin)
    given_im_signed_in_as(:admin)
    given_a(:pay_period)
    
    Given "purchases for two different creators" do
      @purchase = Factory(:purchase)
      @purchase2 = Factory(:purchase)
    end
    
    When "the first pay period is marked as paid" do
      @pay_period.create_line_items
      visit admin_pay_period_path(@pay_period)
      click_button "Mark as paid"
    end
    
    Then "all purchases should have associated line items" do
      assert_equal 0, Purchase.where(:pay_period_line_item_id => nil).count
    end
    
    When "two new purchases are made for two separate creators" do
      story = @purchase.story
      @purchase3 = Purchase.create(:amount => story.price, :story_id => story.id, :payer_id => @email_confirmed_user.id, :payee_id => story.user_id)
      story2 = @purchase2.story
      @purchase4 = Purchase.create(:amount => story2.price, :story_id => story2.id, :payer_id => @email_confirmed_user.id, :payee_id => story2.user_id)
    end
    
    And "another pay period is created" do
      @pay_period2 = Factory(:pay_period)
      @pay_period2.update_attribute(:end, Time.now)
      @pay_period2.create_line_items
    end
    
    And "I visit the pay period page" do
      visit admin_pay_period_path(@pay_period2)
    end
    
    And "I click the mark as paid button" do
      click_button "Mark as paid"
    end
    
    Then "the pay period should have two purchases" do
      assert_equal 2, @pay_period2.purchases.count
    end
    
    And "the pay period should have two payments to the appropriate creators" do
      assert_equal 2, @pay_period2.payments.count
      @pay_period2.line_items.each do |line_item|
        assert_equal line_item.amount, line_item.payee.payments.last.amount
      end
    end
    
    And "each Creator that was paid should have a balance of 0" do
      @pay_period2.line_items.each do |line_item|
        assert_equal 0, line_item.payee.balance
      end
    end
    
    And "the pay period should be marked as paid" do
      assert PayPeriod.last.paid?
    end

    And "all purchases should have associated line items" do
      assert_equal 0, Purchase.where(:pay_period_line_item_id => nil).count
    end
  end
  
end
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
  
  Scenario "An admin wants to view a CSV of the line items for a previous pay period" do
    given_a(:admin)
    given_im_signed_in_as(:admin)
    given_a(:pay_period)
    
    when_i_visit_page(:admin_pay_periods)
    
    And "I click the download csv link" do
      click_link "Download CSV"
    end
    
    Then "I should get back a CSV file" do
      i = 0
      line_items = @pay_period.line_items
      FasterCSV.parse(page.body, :headers => true) do |row|
        assert_equal line_items[i].payee.name, row[0].strip
        assert_equal number_to_currency(line_items[i].amount), row[1].strip
        i += 1
      end
    end
  end
  
end
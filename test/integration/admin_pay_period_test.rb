require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "Admins can create a pay period to pay requested creator cashouts" do

  in_order_to "pay out requested cashouts"
  as_a "admin"
  i_want_to "create a new pay period that pays the necessary creators"
  
  Scenario "An admin ends a pay period" do
    given_a :creator
    
    Given "ten dollars in funded rewards for that creator, and some unfunded" do
      @reward = Factory(:reward, amount: 10, recipient: @creator)
      reward2 = Factory(:unfunded_reward, recipient: @creator)
    end
    
    given_a :admin
    
    given_im_signed_in_as(:admin)
    
    when_i_visit_page(:admin_pay_periods)
    
    And "I click the link to see current unpaid creators" do
      click_link "View Unpaid Creators"
    end
    
    Then "I should see the creator's name and amount of funded rewards we need to pay" do
      assert page.has_content?(@creator.name)
      assert page.has_content?(number_to_currency(@reward.amount))
    end
    
    When "I click the End Payout button" do
      click_button "End Pay Period"
    end
    
    Then "there should be a new pay period with a line item for each creator" do
      pay_period = PayPeriod.last
      assert_equal @admin, pay_period.user
      assert_equal 1, pay_period.line_items.count

      line_item = pay_period.line_items.first
      assert_equal 1, line_item.rewards.count
      assert_equal @reward, line_item.rewards.first

      assert_equal 1, pay_period.creators.count
      assert_equal @reward.recipient, pay_period.creators.first
      
      assert_equal @reward.amount * 0.8, pay_period.amount
    end
  end
  
  Scenario "An admin marks a line item (a creator) as paid" do
    given_a :pay_period
    
    given_a :admin
    
    given_im_signed_in_as(:admin)
    
    When "I visit the pay period's details page" do
      visit admin_pay_period_path(@pay_period)
    end
    
    And "I click the Mark as Paid button on the creator's line item" do
      click_button "Mark as Paid"
    end
    
    Then "the line item should be marked as paid" do
      @pay_period.reload
      @pay_period_line_item = @pay_period.line_items.first
      assert @pay_period_line_item.is_paid?, "the line item is paid"
    end
    
    And "the creator should have been emailed" do
      mail = ActionMailer::Base.deliveries.last
      assert_equal @pay_period_line_item.payee.email, mail["to"].to_s
      assert_equal "Momeant just paid you #{number_to_currency(@pay_period_line_item.amount)}!", mail["subject"].to_s
    end
  end
  
end
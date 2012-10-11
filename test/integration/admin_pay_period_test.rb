require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "Admins can create a pay period to pay requested creator cashouts" do

  in_order_to "pay out requested cashouts"
  as_a "admin"
  i_want_to "create a new pay period that pays the necessary creators"
  
  Scenario "An admin can see how much in unpaid cashouts there are" do
    given_a :creator
    
    Given "ten dollars in funded rewards for that creator, and some unfunded" do
      @reward = Factory(:reward, amount: 10, recipient: @creator)
      reward2 = Factory(:unfunded_reward, recipient: @creator)\
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
    
    Then "there should be a new pay period with a line item paying this creator" do
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
    
    And "the creator should have been emailed" do
      mail = ActionMailer::Base.deliveries.last
      assert_equal @creator.email, mail["to"].to_s
      assert_equal "Momeant is paying you #{number_to_currency(PayPeriod.last.amount)}!", mail["subject"].to_s
    end
  end
  
end
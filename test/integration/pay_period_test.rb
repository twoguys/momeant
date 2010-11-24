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
    
    when_i_visit_page(:pay_periods)
    
    When "I click end current pay period" do
      click_button("End current pay period")
    end
    
    Then "I should be on the new pay period page" do
      assert_equal pay_period_path(PayPeriod.last), current_path
    end
    
    And "I should see a pay period line item for each creator that needs to be paid" do
      line_item_amount = @purchase.amount + @second_purchase.amount
      assert page.has_content? number_to_currency(line_item_amount)
    end
  end
  
end
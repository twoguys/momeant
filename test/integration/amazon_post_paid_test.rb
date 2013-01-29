require 'test_helper'

Feature "A user should be able to pay for rewards using Amazon Payments" do
  extend RewardSteps

  in_order_to "easily pay for rewards"
  as_a "user"
  i_want_to "be able to configure and use Amazon Payments"

  Scenario "Authorizing Amazon Payments" do
    given_a(:user)
    given_im_signed_in_as(:user)
    
    when_i_visit_page(:fund_rewards)
    
    And "I authorize with Amazon" do
      visit "#{root_path}#{RewardSteps::SUCCESSFUL_AUTHORIZATION}"
    end
    
    Then "I should have the Amazon attributes set on my account" do
      @user.reload
      assert @user.amazon_credit_instrument_id.present?, "The amazon credit instrument id is present"
      assert @user.amazon_credit_sender_token_id.present?, "The amazon sender token id is present"
      assert @user.amazon_settlement_token_id.present?, "The amazon settlement token id is present"
      assert @user.has_configured_postpaid?
    end
  end
  
  Scenario "Rewarding underneath the credit instrument limit" do
    Given "a postpaid user and story" do
      @postpaid_user = Factory(:postpaid_user)
      @story = Factory(:story)
      RewardSteps.fake_successful_pay
    end
    
    given_im_signed_in_as(:postpaid_user)
    
    when_i_reward(:story, 0.5)
    
    Then "there should be one Amazon Payment for our Pay request (attributing debt)" do
      FakeWeb.clean_registry
  
      assert_equal 1, @postpaid_user.amazon_payments.count
  
      payment = @postpaid_user.amazon_payments.first
      assert_equal "Pay", payment.used_for
      assert_equal 0.5, payment.amount
      assert_equal "pending", payment.state
      
      assert_equal payment.id, @postpaid_user.given_rewards.first.amazon_payment_id
    end
  end
  
  Scenario "Rewarding equal to the credit instrument limit" do
    Given "a postpaid user and story" do
      @postpaid_user = Factory(:postpaid_user)
      @story = Factory(:story)
      RewardSteps.fake_successful_pay_and_settle
    end
    
    given_im_signed_in_as(:postpaid_user)
    
    when_i_reward(:story, 1.0)
    
    Then "there should be two Amazon Payments marking the debt attributed and the debt settled" do
      FakeWeb.clean_registry
      
      assert_equal 2, @postpaid_user.amazon_payments.count
      
      payment = @postpaid_user.amazon_payments.last
      assert_equal payment.id, @postpaid_user.given_rewards.first.amazon_payment_id
      assert_equal "pending", payment.state
      assert_equal "Pay", payment.used_for
      
      @settle_payment = @postpaid_user.amazon_payments.first
      assert_equal "SettleDebt", @settle_payment.used_for
      assert_equal "pending", @settle_payment.state
      assert_equal @settle_payment.id, @postpaid_user.given_rewards.first.amazon_settlement_id
    end
    
    When "the IPN notification tells us the SettleDebt properly succeeded" do
      post "#{root_path}amazon/update_status?transactionId=#{@settle_payment.amazon_transaction_id}&transactionStatus=SUCCESS"
    end
    
    Then "the reward should be marked as funded" do
      assert_equal 0, @postpaid_user.given_rewards.pledged.count
    end
  end
  
  Scenario "Rewarding above my remaining credit instrument balance" do
    Given "a postpaid user with a small remaining amazon credit balance" do
      @postpaid_user = Factory(:postpaid_user)
      RewardSteps.fake_insufficient_balance
    end
    
    given_a(:story)
    
    given_im_signed_in_as(:postpaid_user)
    
    when_i_reward(:story, 1.0)
    
    Then "the user should be marked as needing to reauthorize their Amazon Payment method" do
      FakeWeb.clean_registry
      
      @postpaid_user.reload
      assert @postpaid_user.needs_to_reauthorize_amazon_postpaid?, "The user is marked as needing to reauthorize Amazon Payments"
    end
    
    And "the reward should have been deleted" do
      assert_equal 0, @postpaid_user.given_rewards.count
    end
    
  end
  
  Scenario "Re-authorizing my Amazon Payment" do
    Given "a postpaid user who needs to reauthorize their Amazon Payment" do
      @postpaid_user = Factory(:postpaid_user, needs_to_reauthorize_amazon_postpaid: true)
    end
    
    given_im_signed_in_as(:postpaid_user)
    
    When "I reauthorize my Amazon Payment" do
      visit "#{root_path}#{RewardSteps::SUCCESSFUL_AUTHORIZATION_2}"
    end
    
    Then "my amazon information should be updated" do
      old_amazon_credit_instrument_id = @postpaid_user.amazon_credit_instrument_id
      old_amazon_credit_sender_token_id = @postpaid_user.amazon_credit_sender_token_id
      old_amazon_settlement_token_id = @postpaid_user.amazon_settlement_token_id
      
      @postpaid_user.reload
      
      assert_not_equal old_amazon_credit_instrument_id, @postpaid_user.amazon_credit_instrument_id
      assert_not_equal old_amazon_credit_sender_token_id, @postpaid_user.amazon_credit_sender_token_id
      assert_not_equal old_amazon_settlement_token_id, @postpaid_user.amazon_settlement_token_id
      
      assert_equal "I7GIB3T3Q8EU2ZK9CBAI31FJXY9DB7G2F8QF78HCDA7VM3MB6QTQFQTFHZZGD3DG", @postpaid_user.amazon_credit_instrument_id
      assert_equal "I5GIP373QXEV2ZA9JBAQ3FFJ3YQDB2GBF8TF68H8D37VL3LB6VTJFQ4F9ZZ6DZDK", @postpaid_user.amazon_credit_sender_token_id
      assert_equal "I1GII2G2QUE82ZI9DBA534FJNYZDB7G8F8JFS8HHDC7VL36B6BT3FQ9FJZZFDKD6", @postpaid_user.amazon_settlement_token_id
      assert !@postpaid_user.needs_to_reauthorize_amazon_postpaid?, "The user does not need to re-auth anymore"
    end
  end
  
  Scenario "Authorizing my Amazon Payment with existing pledged rewards under the one dollar settle debt limit" do
    given_a :postpaid_user
    Given "this user has a 0.5 dollars pledged reward" do
      @reward = Factory(:unfunded_reward, user: @postpaid_user, amount: 0.5)
    end
    
    given_im_signed_in_as(:postpaid_user)
    
    When "I authorize my Amazon Payment" do
      RewardSteps.fake_successful_pay
      visit "#{root_path}#{RewardSteps::SUCCESSFUL_AUTHORIZATION}"
    end
    
    Then "my reward should have an associated Amazon Payment object with it" do
      FakeWeb.clean_registry
  
      assert_equal 1, @postpaid_user.amazon_payments.count
      
      @reward.reload
      payment = @postpaid_user.amazon_payments.first
      assert_equal payment.id, @reward.amazon_payment_id
      assert_equal "Pay", payment.used_for
      assert_equal "pending", payment.state
    end
  end
  
  Scenario "Authorizing my Amazon Payment with existing pledged rewards at the one dollar settle debt limit" do
    given_a :postpaid_user
    Given "this user has a one dollar pledged reward" do
      @reward = Factory(:unfunded_reward, user: @postpaid_user, amount: 1)
    end
    
    given_im_signed_in_as(:postpaid_user)
    
    When "I authorize my Amazon Payment" do
      RewardSteps.fake_successful_pay_and_settle
      visit "#{root_path}#{RewardSteps::SUCCESSFUL_AUTHORIZATION}"
    end
    
    Then "I should have the necessary Amazon Pay and SettleDebt transactions" do
      FakeWeb.clean_registry
  
      assert_equal 2, @postpaid_user.amazon_payments.count
      
      @reward.reload
      payment = @postpaid_user.amazon_payments.last
      assert_equal payment.id, @reward.amazon_payment_id
      assert_equal "Pay", payment.used_for
      assert_equal "pending", payment.state
      
      @settle_payment = @postpaid_user.amazon_payments.first
      assert_equal @settle_payment.id, @reward.amazon_settlement_id
      assert_equal "SettleDebt", @settle_payment.used_for
      assert_equal "pending", @settle_payment.state
    end
    
    When "the IPN notification tells us the SettleDebt properly succeeded" do
      post "#{root_path}amazon/update_status?transactionId=#{@settle_payment.amazon_transaction_id}&transactionStatus=SUCCESS"
    end
    
    Then "the reward should be marked as funded" do
      assert_equal 0, @postpaid_user.given_rewards.pledged.count
    end
  end
  
  Scenario "Receiving a success IPN from Amazon for a Pay transaction" do
    given_a :amazon_payment
    
    When "Amazon sends us an IPN about the previous Pay transaction" do
      post "#{root_path}amazon/update_status?transactionId=#{@amazon_payment.amazon_transaction_id}&transactionStatus=SUCCESS"
    end
    
    Then "the amazon payment status should be updated" do
      @amazon_payment.reload
      assert_equal "success", @amazon_payment.state
    end
  end
  
  Scenario "Receving a success IPN from Amazon for a SettleDebt transaction" do
    given_a :amazon_settle_payment
    
    Given "some rewards associated with that settle payment" do
      @reward = Factory(:reward, amazon_payment_id: @amazon_settle_payment.id)
      @reward2 = Factory(:reward, user_id: @reward.user_id, amazon_payment_id: @amazon_settle_payment.id)
    end
    
    When "Amazon sends us a success IPN about the previous SettleDebt transaction" do
      post "#{root_path}amazon/update_status?transactionId=#{@amazon_settle_payment.amazon_transaction_id}&transactionStatus=SUCCESS"
    end
    
    Then "the settle debt payment should be marked as successful" do
      @amazon_settle_payment.reload
      assert_equal "success", @amazon_settle_payment.state
    end
    
    And "the rewards should be marked as funded" do
      @reward.reload
      @reward2.reload
      assert @reward.paid_for, "The reward is marked as paid for"
      assert @reward2.paid_for, "The reward is marked as paid for"
    end
  end
  
  Scenario "Receiving a failure IPN from Amazon for a Pay transaction" do
    given_a :amazon_payment
    
    When "Amazon sends us an IPN about the previous Pay transaction" do
      post "#{root_path}amazon/update_status?transactionId=#{@amazon_payment.amazon_transaction_id}&transactionStatus=FAILURE"
    end
    
    Then "the amazon payment status should be updated" do
      @amazon_payment.reload
      assert_equal "failure", @amazon_payment.state
    end
    
    And "the user should have received an email asking them to update their Amazon Payment method" do
      mail = ActionMailer::Base.deliveries.last
      assert mail.present?, "An email was sent"
      assert_equal @amazon_payment.payer.email, mail["to"].to_s
      assert_equal "Action Needed! Your Amazon Payment method was declined.", mail["subject"].to_s
    end
  end
  
end
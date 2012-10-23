# success
# http://momeant.dev/fund/accept-postpaid?signatureMethod=RSA-SHA1&status=SC&creditSenderTokenID=I5GIP372QXEV2ZA9JBAQ3FFJ3YQDB2GBF8TF68H8D37VL3LB6VTJFQ4F9ZZ6DZDK&creditInstrumentID=I7GIB3T2Q8EU2ZK9CBAI31FJXY9DB7G2F8QF78HCDA7VM3MB6QTQFQTFHZZGD3DG&settlementTokenID=I1GII3G2QUE82ZI9DBA534FJNYZDB7G8F8JFS8HHDC7VL36B6BT3FQ9FJZZFDKD6&signatureVersion=2&signature=VztSCPvJH0s1Hgg7TvLEDB5hF7R3VIXO12BRzuihITwakjzUQlXOyLDUbsbi4ct9YCkyColoUndZ%0AoNlV2mUb%2BRFC6ixatKuUUDjIxOD07Awh7SClNzk4vxVIRouZeP5ROAZpm33tvRnH66XHr%2FEvqdW%2F%0A6NzAw0HOgVFAeRyvixo%3D&certificateUrl=https%3A%2F%2Ffps.sandbox.amazonaws.com%2Fcerts%2F090911%2FPKICert.pem%3FrequestId%3D1mibf30suu4kx9ssye1joafw1mjjdejt45oc7v86z5hifxn41k&expiry=02%2F2017

# error
# http://momeant.dev/fund/accept-postpaid?errorMessage=The+following+input%28s%29+are+not+well+formed%3A[callerReferenceSettlement]&signatureMethod=RSA-SHA1&status=CE&signatureVersion=2&signature=nnY%2Bdk1%2BE%2BWdFk7%2B2PLCXpbuEb5ZqLfXt9l%2BRdcalZsRZ7OMoChwjp008%2BfpiuzmgLLjiC0riC77%0Aua7C36JbbkdlsOflgJOppnvQrylDfvWTVoPYQ2eg0CiuMdQqGqx6NpLsz4ZUuscognGn%2FxoHXD4n%0ANuAxpMkp5Qd4ZguC%2BsU%3D&certificateUrl=https%3A%2F%2Ffps.sandbox.amazonaws.com%2Fcerts%2F090911%2FPKICert.pem%3FrequestId%3D1mibf30suu4kx9ssye1joafw1mjjdejt45oc7v86z5hifxn41k

# Status Codes
# SA - Success status for the ABT payment method.
# SB - Success status for the ACH (bank account) payment method.
# SC - Success status for the credit card payment method.
# SE - System error.
# A - Buyer abandoned the pipeline.
# CE - Specifies a caller exception.
# PE - Payment Method Mismatch Error: Specifies that the user does not have payment method that you have requested.
# NP - There are four cases where the NP status is returned:
#   The payment instruction installation was not allowed on the sender's account, because the sender's email account is not verified
#   The sender and the recipient are the same
#   The recipient account is a personal account, and therefore cannot accept credit card payments
#   A user error occurred because the pipeline was cancelled and then restarted
# NM - You are not registered as a third-party caller to make this transaction. Contact Amazon Payments for more information

AMAZON_SUCCESSFUL_PAY_RESPONSE = "
<PayResponse xmlns=\"http://fps.amazonaws.com/doc/2008-09-17/\">
   <PayResult>
      <TransactionId>14GK6BGKA7U6OU6SUTNLBI5SBBV9PGDJ6UL</TransactionId>
      <TransactionStatus>Pending</TransactionStatus>
   </PayResult>
   <ResponseMetadata>
      <RequestId>c21e7735-9c08-4cd8-99bf-535a848c79b4:0</RequestId>
   </ResponseMetadata>
</PayResponse>"

AMAZON_SUCCESSFUL_SETTLE_DEBT_RESPONSE = "
<SettleDebtResponse xmlns=\"http://fps.amazonaws.com/doc/2008-09-17/\">
  <SettleDebtResult>
    <TransactionId>14GND25ZN3B7O49QVHNASTT98UOBN83NC92</TransactionId>
    <TransactionStatus>Pending</TransactionStatus>
  </SettleDebtResult>
  <ResponseMetadata>
    <RequestId>9ddfbffc-f909-4628-b247-36a5ef3fc7f3:0</RequestId>
  </ResponseMetadata>
</SettleDebtResponse>"

AMAZON_FAILURE_INSUFFICIENT_BALANCE_RESPONSE = "<Response><Errors><Error><Code>InsufficientBalance</Code><Message>The transaction exceeds the account/instrument limits.</Message></Error></Errors><RequestID>c095300c-8462-4576-b4af-127c5e24a84a</RequestID></Response>"

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
      visit "#{root_path}fund/accept-postpaid?signatureMethod=RSA-SHA1&status=SC&creditSenderTokenID=I5GIP372QXEV2ZA9JBAQ3FFJ3YQDB2GBF8TF68H8D37VL3LB6VTJFQ4F9ZZ6DZDK&creditInstrumentID=I7GIB3T2Q8EU2ZK9CBAI31FJXY9DB7G2F8QF78HCDA7VM3MB6QTQFQTFHZZGD3DG&settlementTokenID=I1GII3G2QUE82ZI9DBA534FJNYZDB7G8F8JFS8HHDC7VL36B6BT3FQ9FJZZFDKD6&signatureVersion=2&signature=VztSCPvJH0s1Hgg7TvLEDB5hF7R3VIXO12BRzuihITwakjzUQlXOyLDUbsbi4ct9YCkyColoUndZ%0AoNlV2mUb%2BRFC6ixatKuUUDjIxOD07Awh7SClNzk4vxVIRouZeP5ROAZpm33tvRnH66XHr%2FEvqdW%2F%0A6NzAw0HOgVFAeRyvixo%3D&certificateUrl=https%3A%2F%2Ffps.sandbox.amazonaws.com%2Fcerts%2F090911%2FPKICert.pem%3FrequestId%3D1mibf30suu4kx9ssye1joafw1mjjdejt45oc7v86z5hifxn41k&expiry=02%2F2017"
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
      FakeWeb.register_uri(:get, %r|https://fps\.sandbox\.amazonaws\.com/|, body: AMAZON_SUCCESSFUL_PAY_RESPONSE)
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
    end
  end
  
  Scenario "Rewarding equal to the credit instrument limit" do
    Given "a postpaid user and story" do
      @postpaid_user = Factory(:postpaid_user)
      @story = Factory(:story)
      FakeWeb.register_uri(:get, %r|https://fps\.sandbox\.amazonaws\.com/|, body: AMAZON_SUCCESSFUL_SETTLE_DEBT_RESPONSE)
    end
    
    given_im_signed_in_as(:postpaid_user)
    
    when_i_reward(:story, 1.0)
    
    Then "there should be two Amazon Payments marking the debt sent and the debt settled" do
      FakeWeb.clean_registry
      
      assert_equal 2, @postpaid_user.amazon_payments.count
      
      payment = @postpaid_user.amazon_payments.first
      assert_equal "SettleDebt", payment.used_for
      assert_equal "pending", payment.state
    end
  end
  
  Scenario "Rewarding above my remaining credit instrument balance" do
    Given "a postpaid user with a small remaining amazon credit balance" do
      @postpaid_user = Factory(:postpaid_user, amazon_remaining_credit_balance: 0.5)
      FakeWeb.register_uri(
        :get,
        %r|https://fps\.sandbox\.amazonaws\.com/|,
        body: AMAZON_FAILURE_INSUFFICIENT_BALANCE_RESPONSE,
        status: ["400", "Bad Request"]
      )
    end
    
    given_a(:story)
    
    given_im_signed_in_as(:postpaid_user)
    
    when_i_reward(:story, 1.0)
    
    Then "the user should be marked as needing to reauthorize their Amazon Payment method" do
      FakeWeb.clean_registry
      
      @postpaid_user.reload
      assert @postpaid_user.needs_to_reauthorize_amazon_postpaid?, "The user is marked as needing to reauthorize Amazon Payments"
    end
    
  end
  
end
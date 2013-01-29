module RewardSteps
  
  SUCCESSFUL_AUTHORIZATION = "payments/accept-postpaid?signatureMethod=RSA-SHA1&status=SC&creditSenderTokenID=I5GIP372QXEV2ZA9JBAQ3FFJ3YQDB2GBF8TF68H8D37VL3LB6VTJFQ4F9ZZ6DZDK&creditInstrumentID=I7GIB3T2Q8EU2ZK9CBAI31FJXY9DB7G2F8QF78HCDA7VM3MB6QTQFQTFHZZGD3DG&settlementTokenID=I1GII3G2QUE82ZI9DBA534FJNYZDB7G8F8JFS8HHDC7VL36B6BT3FQ9FJZZFDKD6&signatureVersion=2&signature=VztSCPvJH0s1Hgg7TvLEDB5hF7R3VIXO12BRzuihITwakjzUQlXOyLDUbsbi4ct9YCkyColoUndZ%0AoNlV2mUb%2BRFC6ixatKuUUDjIxOD07Awh7SClNzk4vxVIRouZeP5ROAZpm33tvRnH66XHr%2FEvqdW%2F%0A6NzAw0HOgVFAeRyvixo%3D&certificateUrl=https%3A%2F%2Ffps.sandbox.amazonaws.com%2Fcerts%2F090911%2FPKICert.pem%3FrequestId%3D1mibf30suu4kx9ssye1joafw1mjjdejt45oc7v86z5hifxn41k&expiry=02%2F2017"
  SUCCESSFUL_AUTHORIZATION_2 = "payments/accept-postpaid?signatureMethod=RSA-SHA1&status=SC&creditSenderTokenID=I5GIP373QXEV2ZA9JBAQ3FFJ3YQDB2GBF8TF68H8D37VL3LB6VTJFQ4F9ZZ6DZDK&creditInstrumentID=I7GIB3T3Q8EU2ZK9CBAI31FJXY9DB7G2F8QF78HCDA7VM3MB6QTQFQTFHZZGD3DG&settlementTokenID=I1GII2G2QUE82ZI9DBA534FJNYZDB7G8F8JFS8HHDC7VL36B6BT3FQ9FJZZFDKD6&signatureVersion=2&signature=VztSCPvJH0s1Hgg7TvLEDB5hF7R3VIXO12BRzuihITwakjzUQlXOyLDUbsbi4ct9YCkyColoUndZ%0AoNlV2mUb%2BRFC6ixatKuUUDjIxOD07Awh7SClNzk4vxVIRouZeP5ROAZpm33tvRnH66XHr%2FEvqdW%2F%0A6NzAw0HOgVFAeRyvixo%3D&certificateUrl=https%3A%2F%2Ffps.sandbox.amazonaws.com%2Fcerts%2F090911%2FPKICert.pem%3FrequestId%3D1mibf30suu4kx9ssye1joafw1mjjdejt45oc7v86z5hifxn41k&expiry=02%2F2017"
  ERROR_AUTHORIZATION = "payments/accept-postpaid?errorMessage=The+following+input%28s%29+are+not+well+formed%3A[callerReferenceSettlement]&signatureMethod=RSA-SHA1&status=CE&signatureVersion=2&signature=nnY%2Bdk1%2BE%2BWdFk7%2B2PLCXpbuEb5ZqLfXt9l%2BRdcalZsRZ7OMoChwjp008%2BfpiuzmgLLjiC0riC77%0Aua7C36JbbkdlsOflgJOppnvQrylDfvWTVoPYQ2eg0CiuMdQqGqx6NpLsz4ZUuscognGn%2FxoHXD4n%0ANuAxpMkp5Qd4ZguC%2BsU%3D&certificateUrl=https%3A%2F%2Ffps.sandbox.amazonaws.com%2Fcerts%2F090911%2FPKICert.pem%3FrequestId%3D1mibf30suu4kx9ssye1joafw1mjjdejt45oc7v86z5hifxn41k"
  FAILURE_INSUFFICIENT_BALANCE_RESPONSE = "<Response><Errors><Error><Code>InsufficientBalance</Code><Message>The transaction exceeds the account/instrument limits.</Message></Error></Errors><RequestID>c095300c-8462-4576-b4af-127c5e24a84a</RequestID></Response>"

  SUCCESSFUL_PAY_RESPONSE = "
  <PayResponse xmlns=\"http://fps.amazonaws.com/doc/2008-09-17/\">
     <PayResult>
        <TransactionId>14GK6BGKA7U6OU6SUTNLBI5SBBV9PGDJ6UL</TransactionId>
        <TransactionStatus>Pending</TransactionStatus>
     </PayResult>
     <ResponseMetadata>
        <RequestId>c21e7735-9c08-4cd8-99bf-535a848c79b4:0</RequestId>
     </ResponseMetadata>
  </PayResponse>"

  SUCCESSFUL_SETTLE_DEBT_RESPONSE = "
  <SettleDebtResponse xmlns=\"http://fps.amazonaws.com/doc/2008-09-17/\">
    <SettleDebtResult>
      <TransactionId>14GND25ZN3B7O49QVHNASTT98UOBN83NC92</TransactionId>
      <TransactionStatus>Pending</TransactionStatus>
    </SettleDebtResult>
    <ResponseMetadata>
      <RequestId>9ddfbffc-f909-4628-b247-36a5ef3fc7f3:0</RequestId>
    </ResponseMetadata>
  </SettleDebtResponse>"
  
  def self.fake_successful_pay
    FakeWeb.register_uri(:get, %r|https://fps\.sandbox\.amazonaws\.com/|, body: RewardSteps::SUCCESSFUL_PAY_RESPONSE)
  end
  
  def self.fake_successful_pay_and_settle
    FakeWeb.register_uri(:get, %r|https://fps\.sandbox\.amazonaws\.com/|, [{ body: RewardSteps::SUCCESSFUL_PAY_RESPONSE }, { body: RewardSteps::SUCCESSFUL_SETTLE_DEBT_RESPONSE }])
  end
  
  def self.fake_insufficient_balance
    FakeWeb.register_uri(
      :get,
      %r|https://fps\.sandbox\.amazonaws\.com/|,
      body: RewardSteps::FAILURE_INSUFFICIENT_BALANCE_RESPONSE,
      status: ["400", "Bad Request"]
    )
  end

  def when_i_reward(story_var, amount = 1.0)
    When "I reward the story #{amount} dollars" do
      story = instance_variable_get("@#{story_var}")
      visit reward_story_path(story)
      find(:xpath, "//input[@id='reward_amount']").set amount
      click_button "Give Reward"
    end
  end
  
end
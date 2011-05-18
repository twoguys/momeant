require "test_helper"

Feature "A user should be able to pay for a Momeant subscription" do

  in_order_to "get full access to the site"
  as_a "user"
  i_want_to "be able to pay for a subscription"

  Scenario "A user starts paying for a subscription" do
    given_a(:trial_user)
    given_im_signed_in_as(:trial_user)
    
    when_i_visit_page :subscribe
    
    And "I click the Get a Subscription button" do
      click_link "subscribe1"
    end
    
    And "I fill out and submit my billing info" do
      # stub what's being returned
      mock(Spreedly::Subscriber).find(@trial_user.id) { OpenStruct.new(:active => true, :token => '123xyz', :feature_level => "full") }
    end
    
    Then "Spreedly tells us that a user was updated and we request their updated info from Spreedly" do
      page.driver.post("/users/billing_updates?subscriber_ids=#{@trial_user.id}")
    end
    
    Then "the user should now have an active subscription" do
      @trial_user.reload
      assert @trial_user.active_subscription?
    end
  end
  
  Scenario "A user stops paying (their card goes inactve or something)" do
    given_a(:paying_user)
    
    When "Spreedly tells us that the user was updated and we request their updated info from Spreedly" do
      mock(Spreedly::Subscriber).find(@paying_user.id) { OpenStruct.new(:active => false, :token => '123xyz', :feature_level => "full") }
      page.driver.post("/users/billing_updates?subscriber_ids=#{@paying_user.id}")
    end
    
    Then "the user should now have a disabled subscription" do
      @paying_user.reload
      assert @paying_user.disabled_subscription?
    end
  end
  
  Scenario "A disabled user (they stopped paying) resumes paying" do
    given_a(:disabled_user)
    
    When "Spreedly tells us that the user was updated and we request their updated info from Spreedly" do
      mock(Spreedly::Subscriber).find(@disabled_user.id) { OpenStruct.new(:active => true, :token => '123xyz', :feature_level => "full") }
      page.driver.post("/users/billing_updates?subscriber_ids=#{@disabled_user.id}")
    end
    
    Then "the user should now have an active subscription again" do
      @disabled_user.reload
      assert @disabled_user.active_subscription?
    end
  end
  
end
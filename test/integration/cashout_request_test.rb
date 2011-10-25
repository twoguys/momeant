require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "Creators can request cashouts for the rewards they've earned" do

  in_order_to "get paid for my rewards"
  as_a "creator"
  i_want_to "request a cashout"
  
  Scenario "A creator sees they can cashout on their creations page" do
    given_a :creator
    Given "the creator has received at least 100 rewards" do
      Factory :reward, :recipient => @creator, :amount => 100
    end
    given_im_signed_in_as(:creator)
    
    When "I visit my creations page" do
      visit creations_user_path(@creator)
    end
    
    And "I click the cashout button" do
      click_link "Cash Out"
    end
    
    Then "I should be on my cashouts page" do
      assert_equal user_cashouts_path(@creator), current_path
    end
  end
  
  Scenario "A creator requests a cashout" do
    given_a :creator
    Given "the creator has received at least 100 rewards" do
      Factory :reward, :recipient => @creator, :amount => 100
    end
    given_im_signed_in_as(:creator)
    
    When "I visit my cashouts page" do
      visit user_cashouts_path(@creator)
    end
    
    And "I press the Cash Out Now button" do
      click_button "Cash Out Now"
    end
    
    Then "I should see my requested cash out listed" do
      assert page.has_content? "$10.00"
      assert page.has_content? "requested"
    end
  end
  
end
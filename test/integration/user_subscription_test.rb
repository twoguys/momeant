require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able subscribe to other users whose curations they like" do

  in_order_to "be shown more content I might like"
  as_a "user"
  i_want_to "be able to subscribe to other users"

  Scenario "Visiting a user's page and subscribing to their curations" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    Given "A second user" do
      @user2 = Factory(:email_confirmed_user)
    end
    
    When "I visit another user's page" do
      visit user_path(@user2)
    end
    
    Then "I should be on their profile/curations page" do
      assert_equal current_path, user_path(@user2)
    end
    
    When "I click the subscribe button" do
      click_button("subscribe")
    end
    
    Then "I should be back on their profile page" do
      assert_equal current_path, user_path(@user2)
    end
    
    then_i_should_see_flash(:notice, "You are now subscribed to")
    
    And "I should be subscribed to the user" do
      assert @email_confirmed_user.subscribed_to.include?(@user2)
      assert @user2.subscribers.include?(@email_confirmed_user)
    end
  end
  
end
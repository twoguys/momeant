require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able subscribe to other users whose curations they like and be delivered those stories" do

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
    
    And "I should see an unsubscribe button" do
      assert find_button("unsubscribe").visible?
    end
  end
  
  Scenario "Visiting my own profile page and NOT seeing a subscribe button" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I visit my page" do
      visit user_path(@email_confirmed_user)
    end
    
    Then "I should be on my profile/curations page" do
      assert_equal current_path, user_path(@email_confirmed_user)
    end
    
    And "I should NOT see the subscribe button" do
      assert !page.has_content?("subscribe")
    end
  end
  
  Scenario "Seeing recommended stories from people I subscribe to on my homepage" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    Given "A second user" do
      @user2 = Factory(:email_confirmed_user)
    end
    Given "I'm subscribed to the other user" do
      Subscription.create(:subscriber_id => @email_confirmed_user.id, :user_id => @user2.id)
    end
    given_a(:story)
    Given "Another story" do
      @story2 = Factory(:story)
    end
    Given "Yet another story" do
      @story3 = Factory(:story)
    end
    Given "The other user has recommended stories" do
      Recommendation.create(:story_id => @story.id, :user_id => @user2.id)
      Recommendation.create(:story_id => @story2.id, :user_id => @user2.id)
    end
    
    when_i_visit_page(:home)
    
    Then "I should see links to the stories the other user recommends" do
      @their_recommended_stories = @user2.recommended_stories
      @their_recommended_stories.each do |story|
        assert page.find('#subscribed-to-stories').has_content? story.title
      end
    end
    
    And "I should not see a link to a story they didn't recommend" do
      assert !page.find('#subscribed-to-stories').has_content?(@story3.title)
    end
  end
  
end
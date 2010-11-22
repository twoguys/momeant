require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "A user can acquire a story" do

  in_order_to "get access to Momeant stories"
  as_a "user"
  i_want_to "acquire/purchase a story"
  
  Scenario "A user acquires a free story" do
    Given "An existing user and free story" do
      @user = Factory(:email_confirmed_user)
      @story = Factory(:free_story)
      @original_user_purchases_count = @user.purchases.count
      @original_creator_sales_count = @story.user.sales.count
    end
    
    given_im_signed_in_as(:user)
    
    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    Then "I should see that the story is free to acquire" do
      assert page.find('.price').has_content? "free"
      assert page.find('.price').find('a.buy-it').has_content? "acquire"
    end
    
    When "I click the acquire link" do
      click_link("acquire")
    end
    
    Then "I should be on the story view page" do
      assert_equal story_path(@story), current_path
    end
    
    then_i_should_see_flash(:notice, "This story is now in your library.")
    
    And "I should see the story content" do
      assert page.has_content? @story.title
      assert page.has_content? @story.excerpt
    end
    
    And "I should have one more purchase" do
      assert_equal @user.purchases.count, @original_user_purchases_count + 1
    end
    
    And "The story creator should have one more sale" do
      assert_equal @story.user.sales.count, @original_creator_sales_count + 1
    end
    
    when_i_visit_page(:library)
    
    then_i_should_be_on_page(:library)
    
    Then "I should see a link to the story I just acquired" do
      assert find_link(@story.title).visible?
    end
  end
  
  Scenario "A user purchases a non-free story that they can afford" do
    Given "An existing user with money deposited and non-free story" do
      @user = Factory(:user_with_money)
      @story = Factory(:story)
      @users_original_money_available = @user.money_available
      @creators_original_credits = @story.user.credits
    end
    
    given_im_signed_in_as(:user)

    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    Then "I should see the story's cost and a link to buy it" do
      assert page.find('.price').has_content? "$#{@story.price}"
      assert page.find('.price').find('a.buy-it').has_content? "purchase"
    end
    
    When "I click the acquire link" do
      click_link("purchase")
    end
    
    Then "I should be on the story view page" do
      assert_equal story_path(@story), current_path
    end
    
    then_i_should_see_flash(:notice, "This story is now in your library.")
    
    And "I should see the story content" do
      assert page.has_content? @story.title
      assert page.has_content? @story.excerpt
    end
    
    And "My available money should be decremented the cost of the story" do
      # grab the user out of the DB again to refresh money available
      @user = User.find(@user.id)
      assert_equal @user.money_available, @users_original_money_available - @story.price
    end
    
    And "The Creator's credits should be incremented the cost of the story" do
      # grab the creator out of the DB to refresh their credits
      @creator = Creator.find(@story.user_id)
      assert_equal @creator.credits, @creators_original_credits + @story.price
    end
  end
  
  Scenario "A user views a story they can't afford" do
    Given "An existing user with money deposited and a story that's too expensive" do
      @user = Factory(:user_with_money)
      @story = Factory(:crazy_expensive_story)
    end
    
    given_im_signed_in_as(:user)

    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    Then "I should see the story's cost and a link to buy it" do
      assert page.find('.price').has_content? number_to_currency(@story.price)
      assert page.find('.price').find('a.buy-it').has_content? "purchase"
    end
    
    When "I click the acquire link" do
      click_link("purchase")
    end
    
    then_i_should_be_on_page(:deposits)
    
    then_i_should_see_flash(:alert, "You need to deposit more money in order to purchase that story.")
  end
  
end
require File.expand_path('../test_helper', File.dirname(__FILE__))

include ActionView::Helpers::NumberHelper

Feature "A user can acquire a story" do

  in_order_to "get access to Momeant stories"
  as_a "user"
  i_want_to "acquire/purchase a story"
  
  Scenario "A user acquires a free story" do
    given_a(:email_confirmed_user)
    given_a(:free_story)
    
    given_im_signed_in_as(:email_confirmed_user)
    
    When "I visit the story preview page" do
      @original_user_purchases_count = @email_confirmed_user.purchases.count
      @original_creator_sales_count = @free_story.user.sales.count
      visit preview_story_path(@free_story)
    end
    
    Then "I should see that the story is free to acquire" do
      assert page.find('.price').has_content? "free"
      assert find_button("acquire").visible?
    end
    
    When "I click the acquire link" do
      click_button("acquire")
    end
    
    Then "I should be on the story view page" do
      assert_equal story_path(@free_story), current_path
    end
    
    then_i_should_see_flash(:notice, "This story is now in your library.")
    
    And "I should see the story content" do
      assert page.has_content? @free_story.title
      assert page.has_content? @free_story.excerpt
    end
    
    And "I should have one more purchase" do
      assert_equal @email_confirmed_user.purchases.count, @original_user_purchases_count + 1
    end
    
    And "The story creator should have one more sale" do
      assert_equal @free_story.user.sales.count, @original_creator_sales_count + 1
    end

    And "The story's purchased_count is incremented by one" do
      original_count = @free_story.purchased_count
      @free_story = Story.find(@free_story.id)
      assert_equal @free_story.purchased_count, original_count + 1
    end
    
    when_i_visit_page(:library)
    
    then_i_should_be_on_page(:library)
    
    Then "I should see a link to the story I just acquired" do
      assert find_link(@free_story.title).visible?
    end
  end
  
  Scenario "A user purchases a non-free story that they can afford" do
    given_a(:user_with_money)
    given_a(:story)
    
    given_im_signed_in_as(:user_with_money)

    When "I visit the story preview page" do
      visit preview_story_path(@story)
    end
    
    Then "I should see the story's cost and a link to buy it" do
      assert page.find('.price').has_content? "$#{@story.price}"
      assert find_button("purchase").visible?
    end
    
    When "I click the acquire link" do
      click_button("purchase")
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
      users_original_money_available = @user_with_money.money_available
      # grab the user out of the DB again to refresh money available
      @user_with_money = User.find(@user_with_money.id)
      assert_equal @user_with_money.money_available, users_original_money_available - @story.price
    end
    
    And "The Creator's credits should be incremented the cost of the story" do
      creators_original_credits = @story.user.credits
      # grab the creator out of the DB to refresh their credits
      @creator = Creator.find(@story.user_id)
      assert_equal @creator.credits, creators_original_credits + @story.price
    end
    
    And "The story's purchased_count is incremented by one" do
      original_count = @story.purchased_count
      @story = Story.find(@story.id)
      assert_equal @story.purchased_count, original_count + 1
    end
  end
  
  Scenario "A user views a story they can't afford" do
    given_a(:user_with_money)
    given_a(:crazy_expensive_story)
    
    given_im_signed_in_as(:user_with_money)

    When "I visit the story preview page" do
      visit preview_story_path(@crazy_expensive_story)
    end
    
    Then "I should see the story's cost and a link to buy it" do
      assert page.find('.price').has_content? number_to_currency(@crazy_expensive_story.price)
      assert find_button("purchase").visible?
    end
    
    When "I click the purchase button" do
      click_button("purchase")
    end
    
    then_i_should_be_on_page(:deposits)
    
    then_i_should_see_flash(:alert, "You need to deposit more money in order to purchase that story.")
  end
  
end
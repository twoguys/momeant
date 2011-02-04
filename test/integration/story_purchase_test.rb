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
      assert page.find('.price').find_button("free").visible?
    end
    
    When "I click the free button" do
      click_button("free")
    end
    
    Then "I should be on the story view page" do
      assert_equal story_path(@free_story), current_path
    end
    
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
    
    And "I should have received an email with my purchase receipt" do
      receipt_email = ActionMailer::Base.deliveries.last
      assert_equal receipt_email.subject, "Thank you for your Momeant purchase!"
      assert_equal receipt_email.to[0], @email_confirmed_user.email
      assert receipt_email.body.include?(@free_story.title)
      assert receipt_email.body.include?("Excerpt: #{@free_story.excerpt}")
      assert receipt_email.body.include?("Price: #{number_to_currency(@free_story.price)}")
      assert receipt_email.body.include?(story_path(@free_story))
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
      assert page.find('.price').find_button(number_to_currency(@story.price)).visible?
    end
    
    When "I click the acquire link" do
      click_button(number_to_currency(@story.price))
    end
    
    Then "I should be on the story view page" do
      assert_equal story_path(@story), current_path
    end
    
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

    And "I should have received an email with my purchase receipt" do
      receipt_email = ActionMailer::Base.deliveries.last
      assert_equal receipt_email.subject, "Thank you for your Momeant purchase!"
      assert_equal receipt_email.to[0], @user_with_money.email
      assert receipt_email.body.include?(@story.title)
      assert receipt_email.body.include?("Excerpt: #{@story.excerpt}")
      assert receipt_email.body.include?("Price: #{number_to_currency(@story.price)}")
      assert receipt_email.body.include?(story_path(@story))
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
      assert page.find('.price').find_button(number_to_currency(@crazy_expensive_story.price)).visible?
    end
    
    When "I click the purchase button" do
      click_button(number_to_currency(@crazy_expensive_story.price))
    end
    
    then_i_should_be_on_page(:credits)
    
    then_i_should_see_flash(:alert, "You need more credits in order to purchase that story.")
  end
  
end
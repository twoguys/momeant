require 'test_helper'

Feature "A creator should be able to offer thank yous to patrons" do
  extend RewardSteps
  
  in_order_to "say thank you to my patrons"
  as_a "creator"
  i_want_to "be able to offer things in return for certain levels of support"
  
  Scenario "Creating a new thank you level" do
    given_a :creator
    
    given_im_signed_in_as :creator
    
    When "I visit my profile page" do
      visit user_path(@creator)
    end
    
    And "I click the link to manage my thank you levels" do
      click_link "Manage Thank You Levels"
    end
    
    And "I fill out the form for a new thank you level" do
      fill_in "thank_you_level_amount", with: 50
      fill_in "thank_you_level_item", with: "Screen printed poster"
      fill_in "thank_you_level_description", with: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut."
      click_button "Create Level"
    end
    
    Then "I should be back on my thank you levels page" do
      assert_equal user_thank_you_levels_path(@creator), current_path
    end
    
    And "I should see my new level listed" do
      assert_equal 1, ThankYouLevel.count
      @level = ThankYouLevel.last
      assert page.find("#main").has_content?(@level.item)
    end
  end
  
  Scenario "A patron reaches a thank you level" do
    given_a :user
    given_a :story
    
    given_im_signed_in_as :user
    
    Given "the story's creator has a thank you level for 50 dollars" do
      @thank_you_level = Factory(:thank_you_level, user: @story.user)
      FakeWeb.register_uri(:get, %r|https://fps\.sandbox\.amazonaws\.com/|, [{ body: RewardSteps::SUCCESSFUL_PAY_RESPONSE }, { body: RewardSteps::SUCCESSFUL_SETTLE_DEBT_RESPONSE }])
    end
    
    when_i_reward(:story, 50)
    
    Then "there should be a record of the patron reaching the thank you level" do
      assert_equal 1, @thank_you_level.achievements.count
      assert_equal @user, @thank_you_level.achievers.first
    end
    
    And "the creator should have received an email notifying them of the patron achievement" do
      mail = ActionMailer::Base.deliveries.first
      assert mail.present?, "An email was sent"
      assert_equal @story.user.email, mail["to"].to_s
      assert_equal "A supporter achieved your Thank You Level", mail["subject"].to_s
    end
  end
  
  Scenario "Creating a new thank you level when existing supporters will already meet it" do
    given_a :creator
    
    given_im_signed_in_as :creator
    
    Given "I have a supporter who has already given me 50 dollars" do
      @reward = Factory(:reward, amount: 50, recipient: @creator)
    end
    
    When "I visit my profile page" do
      visit user_path(@creator)
    end
    
    And "I click the link to manage my thank you levels" do
      click_link "Manage Thank You Levels"
    end
    
    And "I fill out the form for a new thank you level at 50 dollars" do
      fill_in "thank_you_level_amount", with: 50
      fill_in "thank_you_level_item", with: "Screen printed poster"
      fill_in "thank_you_level_description", with: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut."
      click_button "Create Level"
    end
    
    Then "my thank you level should have my existing supporter as an achiever" do
      @thank_you_level = ThankYouLevel.last
      assert_equal 1, @thank_you_level.achievements.count
      assert_equal @reward.user, @thank_you_level.achievers.first
    end
    
    And "I should have received an email notifying me of the patron achievement" do
      mail = ActionMailer::Base.deliveries.last
      assert mail.present?, "An email was sent"
      assert_equal @creator.email, mail["to"].to_s
      assert_equal "A supporter achieved your Thank You Level", mail["subject"].to_s
    end
  end
  
  Scenario "Updating a thank you level amount which causes another patron to reach it" do
    given_a :creator
    
    given_im_signed_in_as :creator
    
    Given "I already have a thank you level at 50 dollars" do
      @thank_you_level = Factory(:thank_you_level, amount: 50, user: @creator)
    end
    
    Given "I have a supporter who has rewarded me 35 dollars" do
      @reward = Factory(:reward, amount: 35, recipient: @creator)
    end
    
    When "I change my thank you level amount to be 35 dollars" do
      visit edit_user_thank_you_level_path(@creator, @thank_you_level)
      fill_in "thank_you_level_amount", with: 35
      click_button "Update Level"
    end
    
    Then "my supporter should be marked as achieveing it" do
      assert_equal 1, @thank_you_level.achievements.count
      assert_equal @reward.user, @thank_you_level.achievers.first
    end
    
    And "I should have received an email notifying me so" do
      mail = ActionMailer::Base.deliveries.last
      assert mail.present?, "An email was sent"
      assert_equal @creator.email, mail["to"].to_s
      assert_equal "A supporter achieved your Thank You Level", mail["subject"].to_s
    end
  end
  
end
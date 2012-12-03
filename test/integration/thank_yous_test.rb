require 'test_helper'

Feature "A creator should be able to offer thank yous to patrons" do
  extend RewardSteps
  
  in_order_to "say thank you to my patrons"
  as_a "creator"
  i_want_to "be able to offer things in return for certain levels of support"
  
  Scenario "Creating a new thank you level" do
    given_a :creator
    
    When "I visit my profile page" do
      visit user_path(@creator)
    end
    
    And "I click the link to manage my thank you levels" do
      click_link "Manage Thank You Levels"
    end
    
    And "I fill out the form for a new thank you level" do
      fill_in :thank_you_level_amount, with: "50"
      fill_in :thank_you_level_item, with: "Screen printed poster"
      fill_in :thank_you_level_description, with: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut."
      click_button "Create Level"
    end
    
    Then "I should be back on my thank you levels page" do
      assert_equal thank_yous_user_path(@creator), current_path
    end
    
    And "I should see my new level listed" do
      @level = ThankYouLevel.last
      assert find(@level.item).visible?
    end
    
  end
  
  Scenario "A patron reaches a thank you level" do
    given_a :user
    given_a :story
    
    Given "the story's creator has a thank you level for 50 dollars" do
      @thank_you_level = Factory(:thank_you_level, user: @story.user)
    end
    
    when_i_reward(:story, 50)
    
    Then "there should be a record of the patron reaching the thank you level" do
      assert_equal 1, @thank_you_level.achievements.count
      assert_equal @user, @thank_you_level.achievers.first
    end
    
    And "the creator should have received an email notifying them of the patron achievement" do
      
    end
  end
  
end
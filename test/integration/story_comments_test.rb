require 'test_helper'
include ActionView::Helpers::TextHelper

Feature "A user should be able to comment on a story" do

  in_order_to "have a discussion with the creator and community around a story"
  as_a "user"
  i_want_to "be able to comment on a story"

  Scenario "Commenting on a story from the profile page" do
    given_a(:user)
    Given "the user has rewarded a story" do
      @reward = Factory(:reward, user: @user)
    end
    given_im_signed_in_as(:user)
    
    When "I visit the story's creator's profile page" do
      visit user_path(@reward.recipient)
      @old_comment_count = @reward.story.comment_count
      assert @reward.recipient.patrons.include?(@user)
    end
    
    And "I type a comment and hit post" do
      click_link "0 comments"
      wait_until { page.find("#comment_comment").visible? }
      fill_in "comment_comment", :with => "Here is a sweet comment about your awesome story!"
      click_button "Post"
    end
    
    Then "there should be a new comment assigned to the story" do
      assert_equal "Here is a sweet comment about your awesome story!", @reward.story.comments.last.comment
    end
    
    When "I re-visit the story's creator's profile page" do
      visit user_path(@reward.recipient)
    end
    
    Then "I should see my comment" do
      assert page.has_content? "Here is a sweet comment about your awesome story!"
    end
  end
  
  Scenario "Trying to comment on a story I have not rewarded" do
    given_a(:user)
    given_a(:story)
    given_im_signed_in_as(:user)
    
    When "I visit the story's creator's profile page" do
      visit user_path(@story.user)
      @old_comment_count = @story.comment_count
    end
    
    Then "I should see a message saying I can't comment" do
      assert page.has_content?("#{@story.user.first_name}'s supporters can participate in this discussion.")
    end
  end
end
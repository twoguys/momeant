require File.expand_path('../test_helper', File.dirname(__FILE__))
require 'uri'

Feature "A user should be able to view stories tagged with a specific tag" do

  in_order_to "find similar stories"
  as_a "user"
  i_want_to "view stories by tag"

  Scenario "Clicking a tag link on a story preview page" do
    given_a(:email_confirmed_user)
    given_a(:tagged_story)
    Given "Another story with a matching tag" do
      @tag = @tagged_story.tags.first
      @story2 = Factory(:tagged_story, :tag_list => @tag.name)
    end
    
    When "I visit the first story's preview page" do
      visit preview_story_path(@tagged_story)
    end
    
    And "I click it's first tag link" do
      click_link @tag.name
    end
    
    Then "I should be on the stories-tagged-with page" do
      assert_equal "/stories/tagged_with/#{URI.escape @tag.name}", current_path
    end
    
    And "I should see a link to the other story sharing this tag" do
      assert find_link(@story2.title).visible?
    end
  end
  
  Scenario "Removing a tag from a story you own" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    Given "I have a tagged story" do
      @story = Factory :tagged_story, :user => @email_confirmed_user
      @tag = @story.tags.first
    end
    
    When "I visit my story's preview path" do
      visit preview_story_path(@story)
    end
    
    And "I click the remove icon on a tag" do
      click_link("x")
    end
    
    Then "The tag should be removed from my story" do
      assert @story.tag_list.include?(@tag.name)
    end
  end
  
end
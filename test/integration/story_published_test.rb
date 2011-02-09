require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A new story is in draft by default but can be published by the creator" do

  Scenario "A user tries to preview a story that isn't published yet" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    given_a(:draft_story)
  
    When "I visit the story preview page" do
      visit preview_story_path(@draft_story)
    end

    then_i_should_be_on_page(:home)
    then_i_should_see_flash(:alert, "Sorry, that story has not been published yet.")
  end
  
  Scenario "A user tries to view a story that isn't published yet" do
    given_a(:email_confirmed_user)
    given_im_signed_in_as(:email_confirmed_user)
    given_a(:draft_story)
  
    When "I visit the story preview page" do
      visit preview_story_path(@draft_story)
    end
  
    then_i_should_be_on_page(:home)
    then_i_should_see_flash(:alert, "Sorry, that story has not been published yet.")
  end
  
end
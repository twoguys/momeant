require 'test_helper'

Feature "A user searches stories" do

  Scenario "A user searches for a story" #do
    # given_a(:email_confirmed_user)
    #   given_im_signed_in_as(:email_confirmed_user)
    #   Given "A story with the title 'Axel Rose'" do
    #     @story = Factory :story, :title => "Axel Rose"
    #   end
    #   Given "A story with an author named 'Random Words'" do
    #     creator = Factory :creator, :first_name => "Random", :last_name => "Words"
    #     @author_story = Factory :story, :user => creator
    #   end
    #   Given "A story with the word 'jinx' in the excerpt" do
    #     @jinx_story = Factory :story, :excerpt => 'my cat is named jinx'
    #   end
    #   Given "A story with a title page that says 'cinders'" do
    #     @cinders_story = Factory :story
    #     title_page = TitlePage.create(:story_id => @cinders_story.id)
    #     title_page.medias << PageText.new(:text => "cinders")
    #   end
    #   
    #   when_i_visit_page(:home)
    #   
    #   when_i_search_for "Axel Rose"
    #   
    #   Then "I should see a link to the Axel Rose story" do
    #     assert page.has_content? @story.title
    #   end
    #   
    #   when_i_search_for "Random Words"
    #   
    #   Then "I should see a link to the story by Random Words" do
    #     assert page.has_content? @author_story.title
    #   end
    #   
    #   when_i_search_for "jinx"
    #   
    #   Then "I should see a link to the story with 'jinx' in the excerpt" do
    #     assert page.has_content? @jinx_story.title
    #   end
    #   
    #   when_i_search_for "cinders"
    #   
    #   Then "I should see a link to the story with 'cinders' in the title page" do
    #     assert page.has_content? @cinders_story.title
    #   end
    #   
    #   when_i_search_for "poop"
    #   
    #   Then "I should not see links to any story" do
    #     assert !page.has_content?(@story.title)
    #     assert !page.has_content?(@author_story.title)
    #     assert !page.has_content?(@jinx_story.title)
    #     assert !page.has_content?(@cinders_story.title)
    #   end
    #   
    # end
  
end
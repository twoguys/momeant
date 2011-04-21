require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able to access their and others' content on profile pages" do

  in_order_to "view the creations, curations, comments, and recommendations of mine and others"
  as_a "user of any type"
  i_want_to "see a profile page with a user's content"

  ["email_confirmed_user", "creator", "admin"].each do |user_type|
    Scenario "Visiting my library page as a #{user_type}" do
      given_a(user_type.to_sym)
      given_im_signed_in_as(user_type.to_sym)
      
      if user_type == "creator"
        Given "I have some stories" do
          @story = Factory(:story, :user => @creator)
          @story2 = Factory(:story, :user => @creator)
        end
      end
      
      Given "I'm subscribed to some users who have recommendations" do
        @user_var = instance_variable_get("@#{user_type}")
        subscription = Factory(:subscription, :subscriber => @user_var)
        subscription2 = Factory(:subscription, :subscriber => @user_var)
        @reward = Factory(:reward, :user => subscription.user)
        @reward2 = Factory(:reward, :user => subscription2.user)
      end

      Given "Some users are subscribed to me" do
        Factory(:subscription, :user => @user_var)
        Factory(:subscription, :user => @user_var)
      end
      
      Given "I have some recommendations" do
        Factory(:reward, :user => @user_var)
        Factory(:reward, :user => @user_var)
      end
    
      When "I visit my profile page" do
        visit user_path(@user_var)
      end
    
      Then "I should see my name" do
        assert page.has_content? @user_var.name
      end

      if user_type == "creator"
        And "I should see links to my stories" do
          assert page.find(".created-stories").has_content? @story.title
          assert page.find(".created-stories").has_content? @story2.title
        end
      end
      
      # And "I should see the stories I've rewarded" do
      #   @user_var.given_rewards.each do |reward|
      #     assert page.find(".curatorial-stream").has_content? reward.story.title
      #   end
      # end
      
      And "I should see the stories the users I'm subscribed to have rewarded" do
        assert page.find(".subscribed-to-stream").has_content? @reward.story.title
        assert page.find(".subscribed-to-stream").has_content? @reward2.story.title
      end
      
      And "I should see links to stories Momeant recommends" do
        @user_var.stories_similar_to_my_bookmarks_and_rewards.each do |story|
          assert page.find(".momeant-recommended-stream").has_content? story_path(story)
        end
      end
    
      # if ["creator", "admin"].include? user_type
      #   And "I should see a form to invite other creators" do
      #     assert page.find("form.new_invitation").visible?
      #   end
      # end
      
      And "I should see a list of my bookmarks" do
        @user_var.bookmarks.each do |bookmark|
          assert page.find(".bookmarks").has_content? bookmark.story.title
        end
      end
      
      if user_type == "admin"
        And "I should see links to admin features" do
          assert page.find_link("Pay Periods").visible?
        end
      end
    end
  end
  
  Scenario "Visiting someone else's profile page" do
    
  end
  
end
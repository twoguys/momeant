require File.expand_path('../test_helper', File.dirname(__FILE__))

Feature "A user should be able to access their content on their library/profile page" do

  in_order_to "find my stories and curations"
  as_a "user"
  i_want_to "have a library page with links to my content"

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
    
      when_i_visit_page(:library)
    
      if user_type == "creator"
        Then "I should see links to my stories" do
          assert page.find(".my-stories").has_content? @story.title
          assert page.find(".my-stories").has_content? @story2.title
        end
      end
    
      if ["creator", "admin"].include? user_type
        And "I should see a form to invite other creators" do
          assert page.find("form.new_invitation").visible?
        end
      end
    
      And "I should see a list of my bookmarks" do
        @user_var = instance_variable_get("@#{user_type}")
        @user_var.bookmarks.each do |bookmark|
          assert page.find(".bookmarks").has_content? bookmark.story.title
        end
      end
      
      And "I should see a list of my recommended stories" do
        @user_var.recommendations.each do |recommendation|
          assert page.find(".recommendations").has_content? recommendation.story.title
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
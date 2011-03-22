require 'test_helper'

Feature "An admin should be able to add Momeant adverts" do

  in_order_to "provide user with visual guides to things"
  as_a "admin"
  i_want_to "be able to create new adverts"

  Scenario "Visiting my homepage, browsing to the advert admin, and adding one" do
    given_a :admin
    given_im_signed_in_as :admin
    
    When "I visit my homepage and click the adverts link" do
      visit user_path(@admin)
      click_link "Adverts"
    end
    
    then_i_should_be_on_page :admin_adverts
    
    When "I fill out and submit the form" do
      fill_in :advert_title, :with => "FAQs"
      attach_file :advert_image, File.join(Rails.root, "test/assets", "avatar.png")
      select "FAQ page", :from => :advert_path
      click_button "Create Advert"
    end
    
    Then "a new Advert should exist with the chosen data" do
      @advert = Advert.last
      assert_equal "FAQs", @advert.title
      assert_match /^http:\/\/s3.amazonaws.com/, @advert.image.url
      assert_equal "faq", @advert.path
    end
    
    And "I should be back on the Adverts list page and see it in the list" do
      assert_equal admin_adverts_path, current_path
      assert page.has_content? @advert.title
    end
  end
  
end
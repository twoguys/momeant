module StoryCreationSteps
  
  def and_i_open_the_page_editor
    And "I open the page editor" do
      click_link "Open Page Editor"
    end
  end
  
  def and_i_close_the_page_editor
    And "I close the page editor" do
      click_link "Close Page Editor"
    end
  end
  
  def and_i_choose_the_title_theme_and_fill_in_a_title_for_page(page_number)
    And "I choose the title theme for page #{page_number} and fill in a title" do
      find(".slider").find(".title").click
      fill_in "pages_#{page_number}_title", :with => "Little Red Riding Hood"
    end
  end
  
  def and_i_goto_the_next_page
    And "I goto the next page" do
      find("#next-page").click
    end
  end
  
  def and_i_choose_the_image_theme_and_choose_an_image_and_caption_for_page(page_number)
    And "I choose the image theme for page #{page_number} and choose an image" do
      find(".slider").find(".full-image").click
      attach_file "pages_#{page_number}_image", File.join(Rails.root, "test/assets", "avatar.png")
      fill_in "pages_#{page_number}_caption", :with => "Here is an explanation of what this image is"
    end
  end
  
  def and_i_choose_the_pullquote_theme_and_fill_in_a_quote_for_page(page_number)
    And "I choose the title theme for page #{page_number} and fill in a title" do
      find(".slider").find(".pullquote").click
      fill_in "pages_#{page_number}_quote", :with => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    end
  end
  
end
module StoryCreationSteps
  
  def and_i_open_the_page_editor_to_page(page_number)
    And "I open the page editor to page" do
      find("#preview_#{page_number}").click
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
      fill_in "pages_#{page_number}_text", :with => "Little Red Riding Hood"
    end
  end
  
  def and_i_goto_the_next_page
    And "I goto the next page" do
      find("#next-page").click
    end
  end
  
  def and_i_choose_the_image_theme_and_choose_an_image_and_caption_for_page(page_number)
    And "I choose the image theme for page #{page_number} and choose an image" do
      find(".slider").find(".full_image").click
      attach_file "pages_#{page_number}_image", File.join(Rails.root, "test/assets", "avatar.png")
      fill_in "pages_#{page_number}_text", :with => "Here is an explanation of what this image is"
    end
  end
  
  def and_i_choose_the_pullquote_theme_and_fill_in_a_quote_for_page(page_number)
    And "I choose the title theme for page #{page_number} and fill in a title" do
      find(".slider").find(".pullquote").click
      fill_in "pages_#{page_number}_text", :with => "Here is a great quote."
    end
  end
  
  def and_i_choose_the_video_theme_and_fill_in_a_vimeo_id_for_page(page_number)
    And "I choose the video theme for page #{page_number} and fill in a Vimeo ID" do
      find(".slider").find(".video").click
      fill_in "pages_#{page_number}_text", :with => "18427511"
    end
  end
  
  def and_i_choose_the_split_theme_and_choose_a_picture_and_text_for_page(page_number)
    And "I choose the split theme for page #{page_number} and choose a picture and text" do
      find(".slider").find(".split").click
      attach_file "pages_#{page_number}_image", File.join(Rails.root, "test/assets", "avatar.png")
      fill_in "pages_#{page_number}_text", :with => "Here is a great quote."
    end
  end
  
  def and_i_choose_the_grid_theme_and_choose_pictures_and_text_for_page(page_number)
    And "I choose the grid theme for page #{page_number} and choose pictures and text" do
      find(".slider").find(".grid").click
      8.times do |num|
        cell = num + 1
        within("#cell_#{cell}") do
          attach_file "pages_#{page_number}_cells_#{cell}_image", File.join(Rails.root, "test/assets", "avatar.png")
          click_link("Edit caption")
          fill_in "pages_#{page_number}_cells_#{cell}_text", :with => "Lorem ipsum dolor sit amet"
        end
      end
    end
  end
  
  def and_i_choose_the_thumbnail_as_page(page_number)
    And "I choose page #{page_number} as the thumbnail preview" do
      find("#preview_#{page_number}").find(".choose-thumbnail").click
    end
  end
  
end
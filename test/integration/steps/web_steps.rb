module WebSteps

  def when_i_visit_page(named_path, eval_block = false, & block)
    When "I visit my #{named_path} page" do
      #TODO: extract page_url (used in then_i_should_be_on_page and when_i_visit_page)
      if block
        args = eval_block ? eval(block.call) : block.call
      end
      page_url = send("#{named_path}_url", args)

      visit page_url
    end
  end
  
  def then_i_should_be_on_page(named_path)
    Then "I should be on the #{named_path} page" do
      page_url = polymorphic_path("#{named_path}")
      assert_equal page_url, current_path
    end
  end
  
  def then_i_should_see_flash(level, message)
    And "I should see the flash #{level} '#{message}'" do
      assert find("#flash").find(".#{level}").has_content? message
    end
  end
  
  def given_im_signed_in_as(var_name)
    Given "I'm signed in as a #{var_name}" do
      visit new_user_session_path
      user = instance_variable_get("@#{var_name}")
      fill_in "user_email", :with => user.email
      fill_in "user_password", :with => "password"
      click_button "Sign in"
    end
  end
end
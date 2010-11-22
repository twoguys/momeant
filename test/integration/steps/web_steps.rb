module WebSteps

  def when_i_visit_page(named_path, eval_block = false, & block)
    When "I visit the #{named_path} page" do
      if block
        args = eval_block ? eval(block.call) : block.call
      end
      page_url = send("#{named_path}_path", args)
      visit page_url
    end
  end
  
  def then_i_should_be_on_page(named_path, eval_block = false, & block)
    Then "I should be on the #{named_path} page" do
      if block
        args = eval_block ? eval(block.call) : block.call
      end
      page_url = send("#{named_path}_path", args)
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
  
  def given_a(model_type)
    Given "A #{model_type.to_s.gsub("_"," ")}" do
      instance_variable_set("@#{model_type}", Factory(model_type))
    end
  end
end
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
      page_url = polymorphic_url("#{named_path}")
      assert_equal page_url, current_url
    end
  end
end
module RewardSteps

  def when_i_reward(story_var, amount = 1.0)
    When "I reward the story #{amount} dollars" do
      story = instance_variable_get("@#{story_var}")
      visit reward_story_path(story)
      find(:xpath, "//input[@id='reward_amount']").set amount
      click_button "Give Reward"
    end
  end
  
end
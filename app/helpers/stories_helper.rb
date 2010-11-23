module StoriesHelper
  
  def bookmark_button(story)
    if current_user.has_bookmarked?(story)
      button_to("unbookmark story", unbookmark_story_path(story))
    else
      button_to("bookmark story", bookmark_story_path(story))
    end
  end
  
  def recommend_button(story)
    if current_user.has_recommended?(story)
      button_to("unrecommend story", unrecommend_story_path(story))
    elsif current_user.recommendation_limit_reached?
      "Recommendation limit reached"
    else
      button_to("recommend story", recommend_story_path(story))
    end
  end
  
end

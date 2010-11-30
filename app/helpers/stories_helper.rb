module StoriesHelper
  
  def bookmark_button(story)
    if current_user
      if current_user.has_bookmarked?(story)
        button_to("unbookmark story", unbookmark_story_path(story), :method => :delete)
      else
        button_to("bookmark story", bookmark_story_path(story))
      end
    end
  end
  
  def recommend_button(story)
    if current_user
      if current_user.has_recommended?(story)
        button_to("unrecommend story", unrecommend_story_path(story), :method => :delete)
      elsif current_user.recommendation_limit_reached?
        "Recommendation limit reached"
      else
        button_to("recommend story", recommend_story_path(story))
      end
    end
  end
  
  def story_price(story)
    if current_user && story.user == current_user
      html = content_tag(:span, "yours", :class => "value")
    elsif current_user && current_user.stories.include?(story)
      html = content_tag(:span, "owned", :class => "value")
      html += link_to("view", @story)
    elsif @story.free?
      html = content_tag(:span, "free", :class => "value")
      html += button_to("acquire", purchase_story_path(@story), :class => "buy-it")
    else
      html = content_tag(:span, number_to_currency(@story.price), :class => "value")
      html += button_to("purchase", purchase_story_path(@story), :class => "buy-it")
    end
    html
  end
  
end

module StoriesHelper
  
  def bookmark_button(story)
    if current_user
      if current_user.has_bookmarked?(story)
        button_to("unbookmark story", unbookmark_story_path(story), :method => :delete, :class => "unbookmark")
      else
        button_to("bookmark story", bookmark_story_path(story), :class => "bookmark")
      end
    end
  end
  
  def recommend_button(story)
    if current_user
      if current_user.has_recommended?(story)
        content_tag("div", :class => "unrecommend") do
          html = button_to("unrecommend story", unrecommend_story_path(story), :method => :delete)
          html += tip("Unrecommend")
        end
      elsif current_user.recommendation_limit_reached?
        "Recommendation limit reached"
      else
        content_tag("div", :class => "recommend") do
          html = button_to("recommend story", recommend_story_path(story))
          html += tip("Recommend")
        end
      end
    end
  end
  
  def story_price(story)
    if current_user && (story.user == current_user || current_user.stories.include?(story))
      html = link_to("view", @story)
    elsif @story.free?
      html = button_to("free", purchase_story_path(@story), :class => "buy-it")
      html += tip("Acquire")
    else
      html = button_to(number_to_currency(@story.price), purchase_story_path(@story), :class => "buy-it")
      html += tip("Purchase")
    end
    html
  end
  
end

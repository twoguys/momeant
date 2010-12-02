module StoriesHelper
  
  def bookmark_button(story)
    if current_user
      if current_user.has_bookmarked?(story)
        button_to("unbookmark story", unbookmark_story_path(story), :method => :delete, :class => "unbookmark tooltipped", :title => "Unbookmark")
      else
        button_to("bookmark story", bookmark_story_path(story), :class => "bookmark tooltipped", :title => "Bookmark")
      end
    end
  end
  
  def recommend_button(story)
    if current_user
      if current_user.has_recommended?(story)
        button_to("unrecommend story", unrecommend_story_path(story), :method => :delete, :class => "urecommend tooltipped", :title => "Unrecommend")
      elsif current_user.recommendation_limit_reached?
        "Recommendation limit reached"
      else
        button_to("recommend story", recommend_story_path(story), :class => "recommend tooltipped", :title => "Recommend")
      end
    end
  end
  
  def story_price(story)
    if current_user && (story.user == current_user || current_user.stories.include?(story))
      link_to("view", @story)
    elsif @story.free?
      button_to("free", purchase_story_path(@story), :class => "buy-it", :class => "tooltipped-n", :title => "Acquire")
    else
      button_to(number_to_currency(@story.price), purchase_story_path(@story), :class => "buy-it", :class => "tooltipped-n", :title => "Purchase")
    end
  end
  
end

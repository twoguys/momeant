module StoriesHelper
  include ActsAsTaggableOn::TagsHelper
  
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
        button_to("unrecommend story", unrecommend_story_path(story), :method => :delete, :class => "unrecommend tooltipped", :title => "Unrecommend")
      elsif current_user.recommendation_limit_reached?
        "Recommendation limit reached"
      else
        button_to("recommend story", recommend_story_path(story), :class => "recommend tooltipped", :title => "Recommend")
      end
    end
  end
  
  def like_button(story)
    if current_user
      if current_user.has_liked?(story)
        button_to("unlike story", unlike_story_path(story), :method => :delete, :class => "liked tooltipped", :title => "Unlike")
      else
        button_to("like story", like_story_path(story), :class => "like tooltipped", :title => "Like")
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
  
  def topic_checkbox(topic, story, all_topics)
    content_tag(:li, :class => "topic") do
      html = check_box_tag "topics[#{topic.id}]", 1, story.topics.include?(topic), "topic-id" => topic.id
      html += topic.name
      html += topic_children_checkboxes(topic, story, all_topics)
    end
  end
  
  def topic_children_checkboxes(topic, story, all_topics)
    children = all_topics.reject {|t| t.topic_id != topic.id}
    if children.size > 0
      content_tag(:ul, :class => "children") do
        html = ""
        children.each do |child|
          html += content_tag(:li, :class => "topic child") do
            checkbox = check_box_tag "topics[#{child.id}]", 1, story.topics.include?(child), "topic-id" => child.id
            checkbox += child.name
          end
        end
        html
      end
    end
  end
  
  # - @topics.each do |topic|
  #   %li.topic
  #     = check_box_tag "topics[#{topic.id}]", 1, @story.topics.include?(topic)
  #     = topic.name
  
end

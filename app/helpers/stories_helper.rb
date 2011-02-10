module StoriesHelper
  include ActsAsTaggableOn::TagsHelper
  
  def bookmark_button(story)
    if current_user
      if current_user.has_bookmarked?(story)
        button_to("unbookmark story", unbookmark_story_path(story), :method => :delete, :class => "unbookmark tooltipped", :title => "Unbookmark?")
      else
        button_to("bookmark story", bookmark_story_path(story), :class => "bookmark tooltipped", :title => "Bookmark?")
      end
    end
  end
  
  def recommend_button(story)
    if current_user
      if current_user.has_recommended?(story)
        link_to(pluralize(story.recommendations.count, "recommendation"), unrecommend_story_path(story), :method => :delete, :class => "unrecommend tooltipped", :title => "Unrecommend?")
      elsif current_user.recommendation_limit_reached?
        "Recommendation limit reached"
      else
        link_to(pluralize(story.recommendations.count, "recommendation"), recommend_story_path(story), :method => :post, :class => "recommend tooltipped", :title => "Recommend?")
      end
    end
  end
  
  def like_button(story)
    if current_user
      if current_user.has_liked?(story)
        link_to(pluralize(story.likes.count, "heart"), unlike_story_path(story), :method => :delete, :class => "liked tooltipped", :title => "Unlike?")
      else
        link_to(pluralize(story.likes.count, "heart"), like_story_path(story), :method => :post, :class => "like tooltipped", :title => "Like?")
      end
    end
  end
  
  def story_price(story)
    if current_user && (story.user == current_user || current_user.stories.include?(story))
      link_to("view", story, :class => "view")
    elsif @story.free?
      link_to("free", purchase_story_path(story), :class => "free", :method => :post, :class => "tooltipped-n", :title => "Acquire")
    else
      link_to(number_with_precision(story.price, :precision => 0), purchase_story_path(story), :method => :post, :class => "buy-it", :class => "tooltipped-n", :title => "Buy")
    end
  end
  
  def story_buy_view_link(story)
    if current_user && (story.user == current_user || current_user.stories.include?(story))
      link_to("view story", story, :class => "view")
    elsif story.free?
      link_to("acquire story for free", purchase_story_path(story), :method => :post, :class => "free", :class => "tooltipped", :title => "Acquire")
    else
      link_to("buy story for #{@story.price}", purchase_story_path(story), :method => :post, :class => "buy-it", :class => "tooltipped", :title => "Buy")
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
  
end

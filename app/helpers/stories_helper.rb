module StoriesHelper
  include ActsAsTaggableOn::TagsHelper
  
  def bookmark_button(story)
    if current_user
      if current_user.has_bookmarked?(story)
        button_to("unbookmark story", unbookmark_story_path(story), :method => :delete, :class => "unbookmark tooltipped-n", :title => "Unbookmark?")
      else
        button_to("bookmark story", bookmark_story_path(story), :class => "bookmark tooltipped-n", :title => "Bookmark this story to remember it for later")
      end
    end
  end
  
  def views_link(story)
    content_tag("span", :class => "views") { pluralize(story.view_count, "view") }
  end
  
  def rewards_link(story, not_clickable = false)
    text = pluralize(story.reward_count, "reward coin")
    if story.owner?(current_user)
      content_tag("span", :class => "reward") { text }
    elsif current_user
      disabled = not_clickable ? "disabled" : ""
      if current_user.has_rewarded?(story) 
        link_to(text, "#reward-box", :class => "rewarded tooltipped #{disabled}", :title => "You rewarded this story.")
      else
        link_to(text, "#reward-box", :class => "reward tooltipped #{disabled}", :title => "Reward this story?")
      end
    else
      content_tag("span", :class => "reward tooltipped", :title => "Signup to reward!") { text }
    end
  end
  
  def story_view_link(story)
    if current_user && current_user.can_view_stories?
      link_to("view", story, :class => "view")
    elsif current_user
      link_to("subscribe to view", subscribe_path, :class => "view")
    else
      link_to("join/login to view", "#signup-modal", :class => "view")
    end
  end
  
  def topic_checkbox(topic, story, all_topics)
    content_tag(:li, :class => "topic") do
      html = check_box_tag "topics[#{topic.id}]", 1, story.topics.include?(topic), "topic-id" => topic.id
      html += label_tag "topics_#{topic.id}", topic.name
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
            checkbox += label_tag "topics_#{topic.id}", child.name
          end
        end
        html.html_safe
      end
    end
  end
  
end

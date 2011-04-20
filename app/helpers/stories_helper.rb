module StoriesHelper
  include ActsAsTaggableOn::TagsHelper
  
  def bookmark_button(story)
    if current_user
      if current_user.has_bookmarked?(story)
        button_to("unbookmark story", unbookmark_story_path(story), :method => :delete, :class => "unbookmark tooltipped-n", :title => "Unbookmark?")
      else
        button_to("bookmark story", bookmark_story_path(story), :class => "bookmark tooltipped-n", :title => "Bookmark?")
      end
    end
  end
  
  def views_link(story)
    link_to(pluralize(story.view_count, "view"), "#", :class => "views disabled")
  end
  
  def rewards_link(story)
    text = pluralize(story.reward_count, "reward coin")
    if current_user
      if current_user.has_rewarded?(story)
        link_to(text, "#", :class => "rewarded disabled tooltipped", :title => "You rewarded this story.")
      else
        link_to(text, "#reward-modal", :class => "reward tooltipped", :title => "Reward this story?")
      end
    end
  end
  
  def story_view_link(story)
    if current_user && current_user.can_view_stories?
      link_to("view", story, :class => "view")
    elsif current_user
      link_to("upgrade to view", "#", :class => "view")
    else
      link_to("signup to view", "#", :class => "view")
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
            checkbox += child.name
          end
        end
        html
      end
    end
  end
  
end

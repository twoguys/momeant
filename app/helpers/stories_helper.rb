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
  
  def galleries_list(user)
    user.galleries.collect {|g| [g.name, g.id]} + [["Create new gallery...","-1"]]
  end
  
end

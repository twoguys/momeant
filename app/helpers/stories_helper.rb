module StoriesHelper
  include ActsAsTaggableOn::TagsHelper
  
  def story_creation_bookmarklet
    "javascript:(function(){ window.open('#{root_url}stories/new?url=' + encodeURIComponent(location.href), 'Share on Momeant', 'menubar=no,location=no,scrollbars=yes,status=no,resizable=yes,width=800,height=500'); })();"
  end
  
  def reward_button_html(story, style)
    url = reward_story_url(story)
    javascript = "window.open('#{reward_story_url(story)}', 'Reward', 'menubar=no,location=no,scrollbars=no,status=no,resizable=no,width=800,height=500'); return false;"
    avatar = ""
    case style
    when "light"
      image_url = "http://momeant-production.s3.amazonaws.com/reward_buttons/light-219x34.png"
      width = 219
      height = 34
    when "light-avatar"
      image_url = "http://momeant-production.s3.amazonaws.com/reward_buttons/light-avatar-168x52.png"
      width = 168
      height = 52
      avatar = "<img src=\"#{story.user.avatar.url(:thumbnail)}\" width=\"42\" height=\"42\" style=\"position:absolute;top:5px;left:5px;border:1px solid #ccc;\">"
    when "dark"
      image_url = "http://momeant-production.s3.amazonaws.com/reward_buttons/dark-219x34.png"
      width = 219
      height = 34
    when "dark-avatar"
      image_url = "http://momeant-production.s3.amazonaws.com/reward_buttons/dark-avatar-168x52.png"
      width = 168
      height = 52
      avatar = "<img src=\"#{story.user.avatar.url(:thumbnail)}\" width=\"42\" height=\"42\" style=\"position:absolute;top:4px;left:5px;border:1px solid #333;\">"
    end
    "<a id=\"momeant-reward-button\" href=\"#{url}\" onclick=\"#{javascript}\" style=\"display:block;width:#{width}px;height:#{height}px;position:relative;\"><img src=\"#{image_url}\" width=\"#{width}\" height=\"#{height}\" alt=\"Reward Me on Momeant\">#{avatar}</a>"
  end
  
  def reward_user_button_html(user)
    url = reward_user_url(user)
    javascript = "window.open('#{url}', 'Reward', 'menubar=no,location=no,status=no,width=800,height=500'); return false;"
    image_url = "http://momeant-production.s3.amazonaws.com/reward_buttons/light-plain-141x34.png"
    width = 141
    height = 34
    "<a id=\"momeant-reward-button\" href=\"#{url}\" onclick=\"#{javascript}\" style=\"display:block;width:#{width}px;height:#{height}px;\"><img src=\"#{image_url}\" width=\"#{width}\" height=\"#{height}\" alt=\"Reward my work\"></a>"
  end
  
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

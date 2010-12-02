module ApplicationHelper
  
  def tip(text)
    content_tag("div", text, :class => "tip")
  end
end

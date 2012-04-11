class PullquotePage < Page
  
  def partial_name
    "pullquote"
  end
  
  def css_class
    "pullquote"
  end
  
  def empty?
    return true if self.text_media.nil? || self.text_media.text.blank?
    return false
  end
end
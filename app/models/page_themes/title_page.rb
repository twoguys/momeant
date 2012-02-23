class TitlePage < Page
  
  def partial_name
    "title"
  end
  
  def css_class
    "title"
  end
  
  def empty?
    return true if self.text_media.text.blank?
    return false
  end
end
class SplitPage < Page
  
  def partial_name
    "split"
  end
  
  def css_class
    "split"
  end
  
  def empty?
    page_layout = self.layout || "image-text"
    
    return true if page_layout == "image-text" &&
      self.image_at_position(1).image.url.include?("missing") &&
      self.text_at_position(2).text.blank?
      
    return true if page_layout == "text-image" &&
      self.text_at_position(1).text.blank? &&
      self.image_at_position(2).image.url.include?("missing")
    
    return true if page_layout == "text-text" &&
      self.text_at_position(1).text.blank? &&
      self.text_at_position(2).text.blank?
    
    return true if page_layout == "image-image" &&
      self.image_at_position(1).image.url.include?("missing") &&
      self.image_at_position(2).image.url.include?("missing")
  
    return false
  end
end
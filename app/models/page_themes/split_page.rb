class SplitPage < Page
  
  def image
    self.medias.each do |media|
      return media if media.is_a?(PageImage)
    end
    return nil
  end
  
  def text   
    self.medias.each do |media|
      return media if media.is_a?(PageText)
    end
    return nil
  end
  
  def partial_name
    "split"
  end
  
  def css_class
    "split"
  end
end
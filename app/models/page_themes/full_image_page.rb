class FullImagePage < Page
  
  def caption
    self.medias.each do |media|
      return media if media.is_a?(PageText)
    end
    return nil
  end

  def partial_name
    "full_image"
  end
  
  def css_class
    "full_image"
  end
end
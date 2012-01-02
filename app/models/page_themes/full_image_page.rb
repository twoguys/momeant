class FullImagePage < Page
  
  def caption
    self.medias.each do |media|
      return media if media.is_a?(PageText)
    end
    return nil
  end
  
  def caption_placement
    placement = self.text_media.placement if self.text_media
    placement ||= "top-right"
  end

  def partial_name
    "full_image"
  end
  
  def css_class
    "full_image"
  end
  
  def empty?
    return true if self.image_media.image.url.include?("missing")
    return false
  end
end
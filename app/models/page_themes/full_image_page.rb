class FullImagePage < Page
  
  IMAGE_PLACEMENTS = {"fill screen" => "fill-screen",
                      "fit to screen" => "fit-to-screen",
                      "original size" => "original"}.freeze
  
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
end
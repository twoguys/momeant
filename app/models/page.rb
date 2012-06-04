class Page < ActiveRecord::Base
  belongs_to :story
  acts_as_list :scope => :story, :column => :number
  has_many :medias, :class_name => "PageMedia", :dependent => :destroy
  
  IMAGE_PLACEMENTS = {
    "original size" => "original",
    "fill screen" => "fill-screen",
    "fit to screen" => "fit-to-screen"
  }.freeze
  
  def image
    self.medias.each do |media|
      return media.image if media.is_a?(PageImage)
    end
    return nil
  end
  
  def image_media
    self.medias.each do |media|
      return media if media.is_a?(PageImage)
    end
    return nil
  end
  
  def text
    self.medias.each do |media|
      return media.text if media.is_a?(PageText)
    end
    return nil
  end
  
  def text_media
    self.medias.each do |media|
      return media if media.is_a?(PageText)
    end
    return nil
  end

  def image_at_position(position)
    self.medias.where(:type => "PageImage", :position => position.to_s).first
  end
  
  def text_at_position(position)
    self.medias.where(:type => "PageText", :position => position.to_s).first
  end
  
  def media_at_position_and_side(position, side)
    self.medias.where(:position => position.to_s, :side => side).first
  end
  
  def has_styles?
    return true if self.background_color
    return true if self.text_color
    return false
  end
  
  def self.create_or_update_page_with(page, options, story)
    if !options || !options[:type]
      Rails.logger.info "[Momeant] Empty options or no page type"
      return false
    end
    if !options[:number]
      Rails.logger.info "[Momeant] No page number"
      return false
    end
    
    if page.nil? && story.page_at(options[:number])
      # the user has chosen to override this page with another
      Rails.logger.info "[Momeant] Overriding page #{options[:number]}"
      story.page_at(options[:number]).destroy
      replacing = true
    end

    case type = options[:type]
    when "title"
      if page
        page.background_color = options[:background_color] if options[:background_color]
        page.text_color = options[:text_color] if options[:text_color]
      else
        page = TitlePage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      if options[:text].present?
        text_media = page.medias.first
        if text_media
          text_media.update_attribute(:text, options[:text])
        else
          page.medias << PageText.new(:text => options[:text])
        end
      end
    when "full_image"
      if page.nil?
        page = FullImagePage.new(:number => options[:number])
      end
      page.background_color = options[:background_color] if options[:background_color]
      image_media = page.image_media
      if image_media.blank?
        page.medias << PageImage.new(:placement => "fill-screen")
        image_media = page.image_media
      end
      if options[:image]
        image_media.image = options[:image]
      end
      if options[:image_placement]
        image_media.update_attribute(:placement, options[:image_placement])
      end
      text_media = page.text_media
      if text_media.blank?
        page.medias << PageText.new
        text_media = page.text_media
      end
      text_media.text = options[:text] if options[:text]
      text_media.background_color = options[:caption_background_color] if options[:caption_background_color]
      text_media.text_color = options[:caption_text_color] if options[:caption_text_color]
      text_media.placement = options[:placement] if options[:placement]
      text_media.save unless page.new_record?
    when "pullquote"
      if page.nil?
        page = PullquotePage.new(:number => options[:number])
      end
      page.background_color = options[:background_color] if options[:background_color]
      text_media = page.text_media
      if text_media.blank?
        page.medias << PageText.new
        text_media = page.text_media
      end
      text_media.text = options[:text] if options[:text]
      text_media.text_style = options[:text_style] if options[:text_style]
      text_media.drop_capped = options[:drop_capped] if options[:drop_capped]
      text_media.save unless page.new_record?
    when "video"
      if page
        page.background_color = options[:background_color]
      else
        page = VideoPage.new(:number => options[:number], :background_color => options[:background_color])
      end
      if page.text_media
        page.text_media.update_attribute(:text, options[:text])
      else
        page.medias << PageText.new(:text => options[:text]) unless options[:text].blank?
      end
    when "split"
      if page
        page.background_color = options[:background_color] if options[:background_color]
        page.text_color = options[:text_color] if options[:text_color]
      else
        page = SplitPage.new(:number => options[:number], :layout => "image-text",:background_color => options[:background_color], :text_color => options[:text_color])
      end
      
      # split pages will have 2 unused PageMedias in the DB, but it's a lot easier than conditionally
      # creating them (data is cheap) and if the user swaps layouts, we still save the unused medias
      # so they could use them again if they swapped layouts back.
      image1 = page.image_at_position(1)
      if image1.blank?
        page.medias << PageImage.new(:position => 1)
        image1 = page.image_at_position(1)
      end
      image2 = page.image_at_position(2)
      if image2.blank?
        page.medias << PageImage.new(:position => 2)
        image2 = page.image_at_position(2)
      end
      text1 = page.text_at_position(1)
      if text1.blank?
        page.medias << PageText.new(:position => 1)
        text1 = page.text_at_position(1)
      end
      text2 = page.text_at_position(2)
      if text2.blank?
        page.medias << PageText.new(:position => 2)
        text2 = page.text_at_position(2)
      end
      
      if options[:image]
        if options[:position] == "1"
          image1.image = options[:image]
        elsif options[:position] == "2"
          image2.image = options[:image]
        end
      end
      
      if options[:text]
        if options[:position] == "1"
          text1.text = options[:text]
        elsif options[:position] == "2"
          text2.text = options[:text]
        end
      end
      
      if options[:image_placement]
        if options[:position] == "1"
          image1.placement = options[:image_placement]
        elsif options[:position] == "2"
          image2.placement = options[:image_placement]
        end
      end
      
      if options[:background_color]
        if options[:position] == "image1"
          image1.background_color = options[:background_color]
        elsif options[:position] == "image2"
          image2.background_color = options[:background_color]
        elsif options[:position] == "text1"
          text1.background_color = options[:background_color]
        elsif options[:position] == "text2"
          text2.background_color = options[:background_color]
        end 
      end
      
      if options[:layout].present?
        page.layout = options[:layout]
      end
      
      unless page.new_record?
        image1.save
        image2.save
        text1.save
        text2.save
      end
    when "grid"
      if page.nil?
        page = GridPage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      
      if options[:position] && options[:side] && options[:text]
        media = page.media_at_position_and_side(options[:position], options[:side])
        if media.nil? || media.is_a?(PageImage)
          media.destroy if media # remove the old image for this position and side
          media = PageText.new(:position => options[:position], :side => options[:side], :text => options[:text])
          page.medias << media
        else
          media.update_attribute(:text, options[:text])
        end
      end
      
      if options[:background_color] && options[:position]
        position = options[:position][12,1]
        side = options[:position].include?("front") ? "front" : "back"
        media = page.media_at_position_and_side(position, side)
        media.update_attribute(:background_color, options[:background_color]) if media
      end
      
      if options[:image_placement] && options[:position] && options[:side]
        position = options[:position]
        side = options[:side]
        media = page.media_at_position_and_side(position, side)
        media.update_attribute(:placement, options[:image_placement]) if media
      end
    when "external"
      if page.nil?
        page = ExternalPage.new(:number => options[:number])
      end
      
      text_media = page.text_media
      if text_media.blank?
        page.medias << PageText.new
        text_media = page.text_media
      end
      text_media.text = options[:text] if options[:text]
      text_media.save unless page.new_record?
    else
      Rails.logger.info "[Momeant] No implementation for page type: #{type}"
      return false
    end
    
    if page
      page.story_id = story.id
      Rails.logger.info "[Momeant] Creating/updating page: #{page.inspect}"
      page.save
      if replacing
        page.insert_at(options[:number])
      end
      return page
    else
      Rails.logger.info "[Momeant] Hmm, no page was made..."
      return false
    end
  end
end
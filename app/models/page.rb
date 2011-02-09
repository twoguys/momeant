class Page < ActiveRecord::Base
  belongs_to :story
  has_many :medias, :class_name => "PageMedia", :dependent => :destroy
  
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
    self.medias.reject {|media| media.type != "PageImage" || media.position != position.to_s}.first
  end
  
  def text_at_position(position)
    self.medias.reject {|media| media.type != "PageText" || media.position != position.to_s}.first
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
    
    if !page && story.page_at(options[:number])
      # the user has chosen to overrite this page with another
      story.page_at(options[:number]).destroy
    end

    case type = options[:type]
    when "title"
      if page
        page.background_color = options[:background_color] if options[:background_color]
        page.text_color = options[:text_color] if options[:text_color]
      else
        page = TitlePage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      unless options[:text].blank?
        text_media = page.medias.first
        if text_media
          text_media.update_attribute(:text, options[:text])
        else
          page.medias << PageText.new(:text => options[:text])
        end
      end
    when "full_image"
      unless page
        page = FullImagePage.new(:number => options[:number])
      end
      page.background_color = options[:background_color] if options[:background_color]
      if options[:image]
        image_media = page.image_media
        if image_media
          image_media.update_attribute(:image, options[:image])
        else
          page.medias << PageImage.new(:image => options[:image])
        end
      end
      text_media = page.text_media
      unless text_media
        page.medias << PageText.new
        text_media = page.medias.last
      end
      text_media.text = options[:text] if options[:text]
      text_media.background_color = options[:caption_background_color] if options[:caption_background_color]
      text_media.text_color = options[:caption_text_color] if options[:caption_text_color]
      text_media.save unless page.new_record?
    when "pullquote"
      if page
        page.background_color = options[:background_color] if options[:background_color]
        page.text_color = options[:text_color] if options[:text_color]
      else
        page = PullquotePage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      unless options[:text].blank?
        text_media = page.text_media
        if text_media
          text_media.update_attributes(:text => options[:text])
        else
          page.medias << PageText.new(:text => options[:text])
        end
      end
    when "video"
      if page
        page.background_color = options[:background_color]
      else
        page = VideoPage.new(:number => options[:number], :background_color => options[:background_color])
      end
      page.medias << PageText.new(:text => options[:text]) unless options[:text].blank?
    when "split"
      if page
        page.background_color = options[:background_color] if options[:background_color]
        page.text_color = options[:text_color] if options[:text_color]
      else
        page = SplitPage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      if options[:image]
        image_media = page.image_media
        if image_media
          image_media.update_attribute(:image, options[:image])
        else
          page.medias << PageImage.new(:image => options[:image])
        end
      end
      unless options[:text].blank?
        text_media = page.text_media
        if text_media
          text_media.update_attributes(:text => options[:text])
        else
          page.medias << PageText.new(:text => options[:text])
        end
      end
    when "grid"
      if page
        page.background_color = options[:background_color] if options[:background_color]
        page.text_color = options[:text_color] if options[:text_color]
      else
        page = GridPage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      if options[:cells]
        8.times do |num|
          cell = (num + 1).to_s
          if options[:cells][cell]
            image = options[:cells][cell][:image]
            caption = options[:cells][cell][:text]
            if image
              image_media = page.image_at_position(cell)
              if image_media
                image_media.update_attribute(:image, image)
              else
                page.medias << PageImage.new(:image => image, :position => cell)
              end
            end
            unless caption.blank?
              text_media = page.text_at_position(cell)
              if text_media
                text_media.update_attributes(:text => caption, :position => cell)
              else
                page.medias << PageText.new(:text => caption, :position => cell)
              end
            end
          end
        end
      end
    else
      Rails.logger.info "[Momeant] No implementation for page type: #{type}"
      return false
    end
    
    if page
      Rails.logger.info "[Momeant] Creating/updating page: #{page.inspect}"
      page.story_id = story.id
      page.save
      return page
    else
      Rails.logger.info "[Momeant] Hmm, no page was made..."
      return false
    end
  end
end
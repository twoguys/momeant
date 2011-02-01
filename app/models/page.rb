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
  
  def self.create_page_type_with(options)
    Rails.logger.info "Creating page with: #{options.inspect}"
    if !options || !options[:type]
      Rails.logger.info "[Momeant] Empty options or no page type"
      return false
    end
    if !options[:number]
      Rails.logger.info "[Momeant] No page number"
      return false
    end
    
    case type = options[:type]
    when "TitlePage"
      page = TitlePage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      unless options[:title].blank?
        page.medias << PageText.new(:text => options[:title])
      end
      return page
    when "FullImagePage"
      page = FullImagePage.new(:number => options[:number], :background_color => options[:background_color])
      page.medias << PageImage.new(:image => options[:image]) if options[:image]
      page.medias << PageText.new(:text => options[:caption], :background_color => options[:caption_background_color], :text_color => options[:caption_text_color]) unless options[:caption].blank?
      return page
    when "PullquotePage"
      page = PullquotePage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      page.medias << PageText.new(:text => options[:quote]) unless options[:quote].blank?
      return page
    when "VideoPage"
      page = VideoPage.new(:number => options[:number], :background_color => options[:background_color])
      page.medias << PageText.new(:text => options[:vimeo_id]) unless options[:vimeo_id].blank?
      return page
    when "SplitPage"
      page = SplitPage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      page.medias << PageImage.new(:image => options[:image]) if options[:image]
      page.medias << PageText.new(:text => options[:text]) unless options[:text].blank?
      return page
    when "GridPage"
      page = GridPage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      if options[:cells]
        8.times do |num|
          cell = (num + 1).to_s
          if options[:cells][cell]
            image = options[:cells][cell][:image]
            caption = options[:cells][cell][:text]
            page.medias << PageImage.new(:image => image, :position => cell) if image
            page.medias << PageText.new(:text => caption, :position => cell) unless caption.blank?
          end
        end
      end
      return page
    else
      Rails.logger.info "[Momeant] No implementation for page type: #{type}"
      return false
    end
  end
  
  def self.create_or_update_page_with(page, options, story)
    Rails.logger.info "Creating/Updating page with: #{options.inspect}"
    if !options || !options[:type]
      Rails.logger.info "[Momeant] Empty options or no page type"
      return false
    end
    if !options[:number]
      Rails.logger.info "[Momeant] No page number"
      return false
    end
    
    case type = options[:type]
    when "TitlePage"
      if page
        page.background_color = options[:background_color]
        page.text_color = options[:text_color]
      else
        page = TitlePage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      return unless options[:title]
      text_media = page.medias.first
      if text_media
        text_media.update_attribute(:text, options[:title])
      else
        page.medias << PageText.new(:text => options[:title])
      end
    when "FullImagePage"
      if page
        page.background_color = options[:background_color]
      else
        page = FullImagePage.new(:number => options[:number], :background_color => options[:background_color])
      end
      if options[:image]
        image_media = page.image_media
        if image_media
          image_media.update_attribute(:image, options[:image])
        else
          page.medias << PageImage.new(:image => options[:image])
        end
      end
      unless options[:caption].blank?
        text_media = page.text_media
        if text_media
          text_media.update_attributes(:text => options[:caption], :background_color => options[:caption_background_color], :text_color => options[:caption_text_color])
        else
          page.medias << PageText.new(:text => options[:caption], :background_color => options[:caption_background_color], :text_color => options[:caption_text_color])
        end
      end
    when "PullquotePage"
      if page
        page.background_color = options[:background_color]
        page.text_color = options[:text_color]
      else
        page = PullquotePage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      unless options[:quote].blank?
        text_media = page.text_media
        if text_media
          text_media.update_attributes(:text => options[:quote])
        else
          page.medias << PageText.new(:text => options[:quote])
        end
      end
    when "VideoPage"
      if page
        page.background_color = options[:background_color]
      else
        page = VideoPage.new(:number => options[:number], :background_color => options[:background_color])
      end
      page.medias << PageText.new(:text => options[:vimeo_id]) unless options[:vimeo_id].blank?
    when "SplitPage"
      if page
        page.background_color = options[:background_color]
        page.text_color = options[:text_color]
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
    when "GridPage"
      if page
        page.background_color = options[:background_color]
        page.text_color = options[:text_color]
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
      page.story_id = story.id
      page.save
    end
  end
end
class Page < ActiveRecord::Base
  belongs_to :story
  has_many :medias, :class_name => "PageMedia", :dependent => :destroy
  
  def image
    self.medias.each do |media|
      return media.image if media.is_a?(PageImage)
    end
    return nil
  end
  
  def text
    self.medias.each do |media|
      return media.text if media.is_a?(PageText)
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
      Rails.logger.info "PAGE TEXTS: #{page.text_at_position(1)}"
      return page
    else
      Rails.logger.info "[Momeant] No implementation for page type: #{type}"
      return false
    end
  end
end
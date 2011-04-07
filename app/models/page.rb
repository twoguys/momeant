class Page < ActiveRecord::Base
  belongs_to :story
  acts_as_list :scope => :story, :column => :number
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
    
    if page.blank? && story.page_at(options[:number])
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
      if options[:text].present?
        text_media = page.medias.first
        if text_media
          text_media.update_attribute(:text, options[:text])
        else
          page.medias << PageText.new(:text => options[:text])
        end
      end
    when "full_image"
      if page.blank?
        page = FullImagePage.new(:number => options[:number])
      end
      page.background_color = options[:background_color] if options[:background_color]
      image_media = page.image_media
      if image_media.blank?
        page.medias << PageImage.new
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
      if page
        page.background_color = options[:background_color] if options[:background_color]
        page.text_color = options[:text_color] if options[:text_color]
      else
        page = PullquotePage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      if options[:text]
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
      if page
        page.background_color = options[:background_color] if options[:background_color]
        page.text_color = options[:text_color] if options[:text_color]
      else
        page = GridPage.new(:number => options[:number], :background_color => options[:background_color], :text_color => options[:text_color])
      end
      if options[:positions]
        8.times do |num|
          position = (num + 1).to_s
          if options[:positions][position]
            image = options[:positions][position][:image]
            caption = options[:positions][position][:text]
            if image
              image_media = page.image_at_position(position)
              if image_media
                image_media.update_attribute(:image, image)
              else
                page.medias << PageImage.new(:image => image, :position => position)
              end
            end
            if caption.present?
              text_media = page.text_at_position(position)
              if text_media
                text_media.update_attributes(:text => caption, :position => position)
              else
                page.medias << PageText.new(:text => caption, :position => position)
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
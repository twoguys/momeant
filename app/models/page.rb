class Page < ActiveRecord::Base
  belongs_to :story
  has_many :medias, :class_name => "PageMedia", :dependent => :destroy
  
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
      page = TitlePage.new(:number => options[:number])
      page.medias << PageText.new(:text => options[:title]) if options[:title]
      return page
    when "FullImagePage"
      page = FullImagePage.new(:number => options[:number])
      page.medias << PageImage.new(:image => options[:image]) if options[:image]
      page.medias << PageText.new(:text => options[:caption]) if options[:caption]
      return page
    when "PullquotePage"
      page = PullquotePage.new(:number => options[:number])
      page.medias << PageText.new(:text => options[:quote]) if options[:quote]
      return page
    when "VideoPage"
      page = VideoPage.new(:number => options[:number])
      page.medias << PageText.new(:text => options[:url]) if options[:url]
      return page
    else
      Rails.logger.info "[Momeant] No implementation for page type: #{type}"
      return false
    end
  end
end
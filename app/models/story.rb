require "open-uri"

class Story < ActiveRecord::Base
  acts_as_taggable
  acts_as_commentable
  
  searchable do
    text :title, :boost => 2.0
    text(:author_name) { user.name }
    text :synopsis
    text :tags do
      tags.map { |tag| tag.name }
    end
    text :pages do
      pages.inject("") { |x,n| x << "#{n.text} " }
    end
    boolean :published
    integer :reward_count
  end
  
  has_attached_file :thumbnail,
    :styles => { :huge => "1440x1200", :large => "630x420#", :medium => "288x180#", :small => "150x100#", :petite => "95x60#" },
    :convert_options => { :huge => '-quality 50' },
    :path          => "story_thumbnails/:id/:style.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET'],
    :processors => [:cropper]
  
  belongs_to :user
  belongs_to :gallery
  has_and_belongs_to_many :topics
  
  has_many :curations, :dependent => :destroy

  has_many :bookmarks, :dependent => :destroy
  has_many :users_who_bookmarked, :through => :bookmarks, :source => :user

  has_many :rewards
  has_many :users_who_rewarded, :through => :rewards, :source => :user, :uniq => true

  has_many :views, :dependent => :destroy
  has_many :users_who_viewed, :through => :views, :source => :user
  
  has_many :pages, :order => "number ASC", :dependent => :destroy
    
  validates :media_type, :presence => true, :unless => :autosaving
  validates :title, :presence => true, :length => (2..256), :unless => :autosaving
  #validates :synopsis, :length => (0..1024), :unless => :autosaving
  #validates_attachment_presence :thumbnail, :unless => :autosaving, :message => "must be chosen"
  validates :i_own_this, :inclusion => {:in => [true], :message => "must be checked"}, :unless => :autosaving
  
  validate  :at_least_one_page, :no_empty_pages, :unless => :autosaving
  
  scope :published, where(:published => true)
  scope :newest_first, order("created_at DESC")
  scope :most_rewarded, order("reward_count DESC")
  scope :no_gallery, where(:gallery_id => nil)
  scope :in_the_past_two_weeks, where("created_at > '#{14.days.ago}'")
  scope :from_today, where("created_at > '#{1.day.ago}'")
  
  paginates_per 12
  
  attr_accessor :autosaving, :crop_x, :crop_y, :crop_width, :crop_height
  
  after_update :reprocess_thumbnail, :if => :cropping?
  before_destroy :destroy_activities
  
  CATEGORIES = [
    "Art",
    "Comics",
    "Design",
    "Education",
    "Film",
    "Food",
    "Music",
    "Photography",
    "Technology",
    "Travel"
  ].freeze
    
  def to_param
    if title.blank?
      "#{id}"
    else
      "#{id}-#{title.gsub(/[^a-zA-Zd0-9]/, '-')}"
    end
  end
  
  def at_least_one_page
    if self.pages.count == 0
      self.errors.add(:base, "Your content must have at least one page")
      return false
    end
    return true
  end
  
  def no_empty_pages
    self.pages.each do |page|
      if page.empty?
        self.errors.add(:base, "Slide #{page.number} cannot be empty. Please fix this by using the fullscreen editor.")
        return false
      end
    end
    return true
  end
  
  def free?
    self.price == 0
  end
  
  def draft?
    !self.published
  end
  
  def topic_list
    self.topics.map{|t| t.name}.join(', ')
  end
  
  def owner?(user)
    user.present? && self.user == user
  end
  
  def liked_by?(user)
    user.present? && self.users_who_liked.include?(user)
  end
  
  def recommended_by?(user)
    user.present? && self.users_who_recommended.include?(user)
  end
  
  def page_at(number)
    return self.pages.find_by_number(number)
  end
  
  def external_text_or_http
    if self.is_external? && self.pages.first.present? && self.pages.first.is_a?(ExternalPage)
      self.pages.first.text
    else
      "http://"
    end
  end
  
  def update_via_opengraph(link)
    metadata = {:title => "", :description => "", :image => ""}
    return metadata if link.blank?
    
    begin
      # lookup OG data to help the user pre-populate metadata
      site = OpenGraph.fetch(link)
      if site
        metadata[:title] = site.title if site.title.present?
        metadata[:description] = site.description if site.description.present?
        metadata[:image] = site.image if site.image.present?
      else
        site = Nokogiri::HTML(open(link))
        title = site.css('title').first
        metadata[:title] = title.content if title
        description = site.css('meta[name="description"]').first
        metadata[:description] = description.content if description
      
        # check for <link rel="image_src">
        image = site.css('link[rel="image_src"]').first
        image = image.attribute("href").to_s if image
      
        # still no image? grab the first <img> tag on the page
        if image.nil?
          image = site.css('img').first
          image = image.attribute("src").to_s if image
        end
        
        # fix relative paths
        if image && !image.match(/^http/)
          image = link + image
        end

        metadata[:image] = image if image
      end
      self.update_with_opengraph_data(metadata)
      self.reload
      metadata[:image] = self.thumbnail.url(:medium)
    rescue
    end
    
    return metadata
  end
  
  def update_with_opengraph_data(metadata)
    # download image and set as thumbnail
    if metadata[:image].present?
      io = open(URI.parse(metadata[:image]))
      def io.original_filename; base_uri.path.split('/').last; end
      self.thumbnail = io.original_filename.blank? ? nil : io
    end
    self.title = metadata[:title]
    self.synopsis = metadata[:description]
    Rails.logger.info "XXXXXXXXXXX - #{self.synopsis}"
    self.autosaving = true
    
    self.save
  end
  
  def download_thumbnail(image_url)
  end
  
  def similar_stories
    # find other stories by my creator
    stories = self.user.created_stories
    
    # find other stories with matching topics
    my_topic_ids = self.topics.map { |topic| topic.id }.join(",")
    stories += Story.joins(:topics).where("topics.id IN (#{my_topic_ids})") unless my_topic_ids.blank?
    
    # remove duplicates and this story
    stories.uniq - [self]
  end
  
  def similar_stories_different_creator
    # find other stories with matching topics
    my_topic_ids = self.topics.map { |topic| topic.id }.join(",")
    stories = []
    stories += Story.published.joins(:topics).where("topics.id IN (#{my_topic_ids})").where("user_id != #{self.user_id}") unless my_topic_ids.blank?
    stories
  end
  
  def determine_thumbnail_colors
    begin
      image =  Magick::Image.read(self.thumbnail.url).first
      histogram = image.color_histogram
    
      # sort by decreasing frequency
      sorted = histogram.keys.sort_by {|p| -histogram[p]}
      most_common_color = sorted.last

      rgb = [sorted.last.red / 257,sorted.last.green / 257,sorted.last.blue / 257]
      hex = rgb.inject("") do |code, color|
        code += color.to_s(16).rjust(2, '0').upcase
      end
    
      self.thumbnail_hex_color = hex
    rescue
    end
  end
  
  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_width.blank? && !crop_height.blank? 
  end
  
  def self.most_rewarded_recently
    Reward.in_the_past_two_weeks.group_by(&:story).to_a.sort {|x,y| y[1].size <=> x[1].size }
  end
  
  def reward_dollars
    self.reward_count * Reward.dollar_exchange
  end
  
  def this_media
    case media_type
    when "photos"
      "these photos"
    when "video"
      "this video"
    when "writing"
      "this article"
    when "music"
      "this music"
    else
      "this content"
    end
  end
  
  def article_string
    case media_type
    when "photos"
      "photos"
    when "video"
      "a video"
    when "writing"
      "an article"
    when "music"
      "some music"
    else
      "some content"
    end
  end
  
  def text_media_type?
    self.media_type == "writing" || self.media_type == "music"
  end
  
  def reload_thumbnail!
    return false if self.thumbnail.url.include?("missing")
    begin
      io = open(URI.parse(self.thumbnail.url))
      self.thumbnail = io
      self.save
    rescue Exception
    end
  end
  
  def activities
    Activity.where(:action_id => self.id).where("action_type = 'Story'")
  end
  
  private
  
  def reprocess_thumbnail
    thumbnail.reprocess!
    self.crop_x = nil
    save
  end
  
  def destroy_activities
    self.activities.destroy_all
  end
end
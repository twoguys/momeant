class LandingIssue < ActiveRecord::Base
  acts_as_list
  belongs_to :curator, class_name: "User"
  
  default_scope order("position ASC")
  scope :published, where(published: true)
  
  has_attached_file :header_background,
    :path          => "landing_issues/:id/header_background.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
    
  has_attached_file :header_title,
    :path          => "landing_issues/:id/header_title.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
  
  def creators
    User.where(id: self.creator_ids.split(","))
  end
  
  def content
    Story.where(id: self.content_ids.split(",")).includes(:user)
  end
  
  def parse_creator_comments
    self.creator_comments.split("---").reject{|s| s.empty? }.map do |s|
      { creator_id: s.split(":", 2).first, comment: s.split(":", 2).last }
    end
  end
  
  def parse_content_comments
    self.content_comments.split("---").reject{|s| s.empty? }.map do |s|
      { content_id: s.split(":", 2).first, comment: s.split(":", 2).last }
    end
  end
  
  def creator_comments_for(id)
    hash = self.parse_creator_comments.select { |c| c[:creator_id] == id.to_s }.first
    hash.present? ? hash[:comment] : ""
  end
  
  def content_comments_for(id)
    hash = self.parse_content_comments.select { |c| c[:content_id] == id.to_s }.first
    hash.present? ? hash[:comment] : ""
  end
end
class LandingIssue < ActiveRecord::Base
  acts_as_list
  belongs_to :curator, class_name: "User"
  
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
    Story.where(id: self.content_ids.split(","))
  end
end
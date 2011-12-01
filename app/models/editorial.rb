class Editorial < ActiveRecord::Base
  belongs_to :user
  
  has_attached_file :background,
    :path          => "editorial_backgrounds/:id/:style.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
  
  SHOW_AS_OPTIONS = [:creator, :patron]
end

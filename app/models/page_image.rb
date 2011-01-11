class PageImage < PageMedia
  has_attached_file :image,
    :styles => { :large => "630x420#", :medium => "288x180#", :small => "150x100#", :petite => "95x60#" },
    :path          => "page_images/:id/:style.:extension",
    :storage        => :s3,
    :s3_credentials => {
      :access_key_id       => ENV['S3_KEY'],
      :secret_access_key   => ENV['S3_SECRET']
    },
    :bucket        => ENV['S3_BUCKET']
end
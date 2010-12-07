class Page < ActiveRecord::Base
  belongs_to :story
  has_many :medias, :class_name => "PageMedia"
end
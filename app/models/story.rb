class Story < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :topics
    
  validates :title, :presence => true, :length => (2..256)
  validates :excerpt, :length => (2..1024)
  validates :price, :format => /[0-9.,]+/
end
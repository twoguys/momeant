class PageMedia < ActiveRecord::Base
  belongs_to :page
  
  scope :with_position, lambda {|position| where(:position => position.to_s)}
end
class PageMedia < ActiveRecord::Base
  belongs_to :page
  
  scope :with_position, lambda {|position| where(:position => position.to_s)}
  
  def has_styles?
    return true if self.background_color
    return true if self.text_color
    return false
  end
end
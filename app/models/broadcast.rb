class Broadcast < ActiveRecord::Base
  acts_as_commentable
  
  belongs_to :user
  
  before_destroy :destroy_activities
  
  def activities
    Activity.where(:action_id => self.id).where("action_type = 'Broadcast'")
  end
  
  private
  
  def destroy_activities
    self.activities.destroy_all
  end
end
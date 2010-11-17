class Invitation < ActiveRecord::Base
  belongs_to :inviter, :class_name => "User"
  
  before_create :generate_token
  
  def invited_as_creator?
    self.invited_as == "Creator"
  end
  
  private
    def generate_token
      self.token = Digest::SHA1.hexdigest("#{Time.now}#{rand(938249832749)}")
    end
end

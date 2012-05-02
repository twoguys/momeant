class Invitation < ActiveRecord::Base
  belongs_to :inviter, :class_name => "User"
  belongs_to :invitee, :class_name => "User"
  
  before_create :set_token
  
  TOKEN_LENGTH = 6
  
  def used?
    self.invitee_id.present?
  end
  
  private
    def set_token
      token = generate_token
      while Invitation.find_by_token(token).present?
        token = generate_token
      end
      self.token = token
    end
  
    def generate_token
      token = ""
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      1.upto(TOKEN_LENGTH) { |i| token << chars[rand(chars.size-1)] }
      return token
    end
end

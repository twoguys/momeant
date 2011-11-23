class Editorial < ActiveRecord::Base
  belongs_to :user
  
  SHOW_AS_OPTIONS = [:creator, :patron]
end

class ImpactCache < ActiveRecord::Base
  belongs_to :user
  belongs_to :recipient
end
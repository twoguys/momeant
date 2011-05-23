class Subscription < ActiveRecord::Base
  belongs_to :subscriber, :class_name => "User"
  belongs_to :user, :counter_cache => true
end

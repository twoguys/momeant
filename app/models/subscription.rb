class Subscription < ActiveRecord::Base
  belongs_to :subscriber, :class_name => "User"
  belongs_to :user, :counter_cache => true
  
  def since
    self.created_at.strftime("%b %e, %Y")
  end
  
  # Reports -------------------------------------------------------------------------
  
  def self.per_day(time)
    by_day = self.where(created_at: (time.ago..Time.now)).group("date_trunc('day',created_at)").count
    (time.ago.to_date..Date.today).to_a.map do |date|
      by_day[date.beginning_of_day.to_s(:db)] || 0
    end
  end
  
end
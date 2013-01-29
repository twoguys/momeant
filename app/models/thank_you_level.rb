class ThankYouLevel < ActiveRecord::Base
  belongs_to :user
  has_many :achievements, class_name: "ThankYouAchievement"
  has_many :achievers, through: :achievements, source: :user
  
  validates :amount, numericality: true
  validates :item, presence: true
  
  default_scope order("amount ASC")
  
  def self.check_for_achievement(user, creator)
    creator.thank_you_levels.each do |level|
      if !level.already_achieved_by?(user.id) && level.reached_by?(user.id)
        ThankYouAchievement.create(user_id: user.id, creator_id: creator.id, thank_you_level_id: level.id)
      end
    end
  end
  
  def check_for_existing_achievers
    ImpactCache.where(recipient_id: self.user_id).where("amount >= ?", self.amount).map(&:user_id).each do |user_id|
      unless already_achieved_by?(user_id)
        ThankYouAchievement.create(user_id: user_id, creator_id: self.user_id, thank_you_level_id: self.id)
      end
    end
  end
  
  def reached_by?(user_id)
    ImpactCache.where(recipient_id: self.user_id, user_id: user_id).where("amount >= ?", self.amount).present?
  end
  
  def already_achieved_by?(user_id)
    self.achievements.where(user_id: user_id).present?
  end
end
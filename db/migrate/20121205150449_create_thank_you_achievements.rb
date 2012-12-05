class CreateThankYouAchievements < ActiveRecord::Migration
  def self.up
    create_table :thank_you_achievements do |t|
      t.integer :thank_you_level_id
      t.integer :user_id
      t.integer :creator_id
      t.boolean :fulfilled

      t.timestamps
    end
  end

  def self.down
    drop_table :thank_you_achievements
  end
end

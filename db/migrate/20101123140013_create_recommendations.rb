class CreateRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.integer :user_id
      t.integer :story_id

      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end

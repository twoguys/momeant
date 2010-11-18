class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :name

      t.timestamps
    end
    
    Topic.create(:name => "Fashion")
    Topic.create(:name => "Design")
    Topic.create(:name => "Photography")
    Topic.create(:name => "Life")
  end

  def self.down
    drop_table :topics
  end
end

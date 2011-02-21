class ChangeStoryPriceToInteger < ActiveRecord::Migration
  def self.up
    old_stories = Story.all
    remove_column :stories, :price
    add_column :stories, :price, :integer
    old_stories.each do |story|
      Story.find(story.id).update_attribute(:price, story.price)
    end
  end

  def self.down
    old_stories = Story.all
    remove_column :stories, :price
    add_column :stories, :price, :float
    old_stories.each do |story|
      Story.find(story.id).update_attribute(:price, story.price)
    end
  end
end

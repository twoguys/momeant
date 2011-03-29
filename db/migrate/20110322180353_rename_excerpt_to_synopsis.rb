class RenameExcerptToSynopsis < ActiveRecord::Migration
  def self.up
    add_column :stories, :synopsis, :text
    
    Story.all.each do |story|
      story.update_attribute(:synopsis, story.excerpt)
    end
    
    remove_column :stories, :excerpt
  end

  def self.down
    add_column :stories, :excerpt, :text
    
    Story.all.each do |story|
      story.update_attribute(:excerpt, story.synopsis)
    end
    
    remove_column :stories, :synopsis
  end
end

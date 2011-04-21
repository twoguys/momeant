class AddCommentCountToStory < ActiveRecord::Migration
  def self.up
    add_column :stories, :comment_count, :integer, :default => 0
    Story.update_all(:comment_count => 0)
  end

  def self.down
    remove_column :stories, :comment_count
  end
end

class CreateStoriesTopicsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :stories_topics, :id => false do |t|
      t.integer :story_id
      t.integer :topic_id
    end
  end

  def self.down
    drop_table :stories_topics
  end
end

class AddParentTopicIdToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :topic_id, :integer
  end

  def self.down
    remove_column :topics, :topic_id
  end
end

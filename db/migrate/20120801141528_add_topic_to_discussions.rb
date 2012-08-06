class AddTopicToDiscussions < ActiveRecord::Migration
  def self.up
    add_column :discussions, :topic, :string
  end

  def self.down
    remove_column :discussions, :topic
  end
end

class AddIOwnThisToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :i_own_this, :boolean, :default => true
    Story.update_all(:i_own_this => true)
  end

  def self.down
    remove_column :stories, :i_own_this
  end
end

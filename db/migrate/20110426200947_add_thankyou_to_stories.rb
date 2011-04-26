class AddThankyouToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :thankyou, :text
  end

  def self.down
    remove_column :stories, :thankyou
  end
end

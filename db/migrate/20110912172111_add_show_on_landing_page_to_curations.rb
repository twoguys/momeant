class AddShowOnLandingPageToCurations < ActiveRecord::Migration
  def self.up
    add_column :curations, :show_on_landing_page, :boolean, :default => false
  end

  def self.down
    remove_column :curations, :show_on_landing_page
  end
end

class AddPublishedToLandingIssues < ActiveRecord::Migration
  def self.up
    add_column :landing_issues, :published, :boolean
  end

  def self.down
    remove_column :landing_issues, :published
  end
end

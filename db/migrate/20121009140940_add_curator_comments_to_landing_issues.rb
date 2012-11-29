class AddCuratorCommentsToLandingIssues < ActiveRecord::Migration
  def self.up
    add_column :landing_issues, :creator_comments, :text
    add_column :landing_issues, :content_comments, :text
  end

  def self.down
    remove_column :landing_issues, :content_comments
    remove_column :landing_issues, :creator_comments
  end
end

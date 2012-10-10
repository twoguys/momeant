class ChangeDefaultForLandingIssueFields < ActiveRecord::Migration
  def self.up
    change_column_default :landing_issues, :creator_comments, ""
    change_column_default :landing_issues, :content_comments, ""
  end

  def self.down
  end
end

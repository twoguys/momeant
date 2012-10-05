class CreateLandingIssues < ActiveRecord::Migration
  def self.up
    create_table :landing_issues do |t|
      t.string :title
      t.integer :position
      
      t.string :header_background_file_name
      t.string :header_background_content_type
      t.integer :header_background_file_size
      t.datetime :header_background_updated_at
      
      t.string :header_title_file_name
      t.string :header_title_content_type
      t.integer :header_title_file_size
      t.datetime :header_title_updated_at
      
      t.integer :curator_id
      t.string :creator_ids
      t.string :content_ids

      t.timestamps
    end
  end

  def self.down
    drop_table :landing_issues
  end
end

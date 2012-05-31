class UpdateEditorialColumns < ActiveRecord::Migration
  def self.up
    add_column :editorials, :story_id, :integer
    
    remove_column :editorials, :show_as
    remove_column :editorials, :background_file_name
    remove_column :editorials, :background_content_type
    remove_column :editorials, :background_file_size
    remove_column :editorials, :background_updated_at
    remove_column :editorials, :occupation
  end

  def self.down
    remove_column :editorials, :story_id
    
    add_column :editorials, :show_as, :string
    add_column :editorials, :background_file_name, :string
    add_column :editorials, :background_content_type, :string
    add_column :editorials, :background_file_size, :integer
    add_column :editorials, :background_updated_at, :datetime
    add_column :editorials, :occupation, :string
  end
end

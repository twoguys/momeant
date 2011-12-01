class AddBackgroundFieldsToEditorials < ActiveRecord::Migration
  def self.up
    add_column :editorials, :background_file_name, :string
    add_column :editorials, :background_content_type, :string
    add_column :editorials, :background_file_size, :integer
    add_column :editorials, :background_updated_at, :datetime
  end

  def self.down
    remove_column :editorials, :background_updated_at
    remove_column :editorials, :background_file_size
    remove_column :editorials, :background_content_type
    remove_column :editorials, :background_file_name
  end
end

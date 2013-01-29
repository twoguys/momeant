class AddUrlToCurations < ActiveRecord::Migration
  def change
    add_column :curations, :content_url, :string
  end
end

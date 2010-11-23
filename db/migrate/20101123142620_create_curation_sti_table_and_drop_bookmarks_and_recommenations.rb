class CreateCurationStiTableAndDropBookmarksAndRecommenations < ActiveRecord::Migration
  def self.up
    create_table :curations do |t|
      t.integer :user_id
      t.integer :story_id
      t.string :type

      t.timestamps
    end
    
    drop_table :bookmarks
    drop_table :recommendations
  end

  def self.down
    create_table :recommendations do |t|
      t.integer :user_id
      t.integer :story_id

      t.timestamps
    end
    create_table :bookmarks do |t|
      t.integer :user_id
      t.integer :story_id

      t.timestamps
    end
    
    drop_table :curations
  end
end

class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :actor_id
      t.integer :recipient_id
      t.integer :action_id
      t.string :action_type

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end

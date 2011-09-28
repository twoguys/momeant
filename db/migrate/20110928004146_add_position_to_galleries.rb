class AddPositionToGalleries < ActiveRecord::Migration
  def self.up
    add_column :galleries, :position, :integer
    
    # set the proper positions for existing galleries
    User.all.each do |user|
      position = 1
      user.galleries.each do |gallery|
        gallery.update_attribute(:position, position)
        position += 1
      end
    end
  end

  def self.down
    remove_column :galleries, :position
  end
end

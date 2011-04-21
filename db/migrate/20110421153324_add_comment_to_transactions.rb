class AddCommentToTransactions < ActiveRecord::Migration
  def self.up
    add_column :transactions, :comment, :text
  end

  def self.down
    remove_column :transactions, :comment
  end
end

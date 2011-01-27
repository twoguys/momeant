class CreateCreditCards < ActiveRecord::Migration
  def self.up
    create_table :credit_cards do |t|
      t.string :last_four_digits
      t.string :braintree_token
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :credit_cards
  end
end

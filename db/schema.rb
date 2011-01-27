# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110126172652) do

  create_table "bookmarked_stories_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "story_id"
  end

  create_table "credit_cards", :force => true do |t|
    t.string   "last_four_digits"
    t.string   "braintree_token"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "curations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "story_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "inviter_id"
    t.boolean  "accepted",      :default => false
    t.string   "invited_as"
    t.string   "invitee_email"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "page_medias", :force => true do |t|
    t.string   "type"
    t.text     "text"
    t.string   "image_file_name"
    t.string   "image_file_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "position"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_color"
    t.string   "text_color"
  end

  create_table "pages", :force => true do |t|
    t.integer  "number"
    t.string   "type"
    t.integer  "story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_color"
    t.string   "text_color"
  end

  create_table "pay_period_line_items", :force => true do |t|
    t.integer  "payee_id"
    t.integer  "pay_period_id"
    t.float    "amount"
    t.integer  "payment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pay_periods", :force => true do |t|
    t.datetime "end"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "paid",       :default => false
  end

  create_table "stories", :force => true do |t|
    t.string   "title"
    t.text     "excerpt"
    t.float    "price"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchased_count", :default => 0
    t.boolean  "published",       :default => false
    t.integer  "thumbnail_page"
  end

  create_table "stories_topics", :id => false, :force => true do |t|
    t.integer "story_id"
    t.integer "topic_id"
  end

  create_table "subscriptions", :force => true do |t|
    t.integer  "subscriber_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "topic_id"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount"
    t.integer  "payee_id"
    t.integer  "payer_id"
    t.string   "type"
    t.integer  "pay_period_line_item_id"
    t.string   "braintree_order_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",   :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                       :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_file_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_udpated_at"
    t.string   "type"
    t.boolean  "is_admin",                            :default => false
    t.float    "money_available",                     :default => 0.0
    t.float    "credits",                             :default => 0.0
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

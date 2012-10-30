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

ActiveRecord::Schema.define(:version => 20121026164119) do

  create_table "activities", :force => true do |t|
    t.integer  "actor_id"
    t.integer  "recipient_id"
    t.integer  "action_id"
    t.string   "action_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "adverts", :force => true do |t|
    t.string   "title"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "path"
    t.boolean  "enabled",            :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "secret"
  end

  create_table "broadcasts", :force => true do |t|
    t.integer  "user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cashouts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "pay_period_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount_old"
    t.decimal  "amount",        :precision => 8, :scale => 2
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50, :default => ""
    t.text     "comment"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reward_id"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

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
    t.text     "comment"
    t.integer  "amount_old",                                            :default => 0
    t.integer  "recipient_id"
    t.boolean  "given_during_trial",                                    :default => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth",                                                 :default => 0
    t.boolean  "show_on_landing_page",                                  :default => false
    t.integer  "cashout_id"
    t.boolean  "shared_to_twitter",                                     :default => false
    t.boolean  "shared_to_facebook",                                    :default => false
    t.integer  "impact",                                                :default => 0
    t.decimal  "amount",                  :precision => 8, :scale => 2
    t.boolean  "paid_for",                                              :default => false
    t.integer  "amazon_payment_id"
    t.integer  "pay_period_line_item_id"
    t.integer  "amazon_settlement_id"
  end

  create_table "discussions", :force => true do |t|
    t.integer  "user_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "topic"
  end

  create_table "editorials", :force => true do |t|
    t.integer  "user_id"
    t.text     "quote"
    t.boolean  "published",  :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "story_id"
  end

  create_table "galleries", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  create_table "impact_caches", :force => true do |t|
    t.integer  "user_id"
    t.integer  "recipient_id"
    t.decimal  "amount",       :precision => 8, :scale => 2, :default => 0.0
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
    t.integer  "invitee_id"
  end

  create_table "landing_issues", :force => true do |t|
    t.string   "title"
    t.integer  "position"
    t.string   "header_background_file_name"
    t.string   "header_background_content_type"
    t.integer  "header_background_file_size"
    t.datetime "header_background_updated_at"
    t.string   "header_title_file_name"
    t.string   "header_title_content_type"
    t.integer  "header_title_file_size"
    t.datetime "header_title_updated_at"
    t.integer  "curator_id"
    t.string   "creator_ids"
    t.string   "content_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "creator_comments",               :default => ""
    t.text     "content_comments",               :default => ""
    t.boolean  "published"
  end

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.boolean  "sender_deleted",    :default => false
    t.boolean  "recipient_deleted", :default => false
    t.text     "body"
    t.datetime "read_at"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
    t.datetime "sender_read_at"
    t.datetime "recipient_read_at"
    t.string   "subject"
  end

  create_table "page_media", :force => true do |t|
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
    t.string   "placement"
    t.string   "side"
    t.string   "text_style"
    t.boolean  "drop_capped",      :default => false
  end

  create_table "pages", :force => true do |t|
    t.integer  "number"
    t.string   "type"
    t.integer  "story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_color"
    t.string   "text_color"
    t.string   "layout"
  end

  create_table "pay_period_line_items", :force => true do |t|
    t.integer  "payee_id"
    t.integer  "pay_period_id"
    t.float    "amount"
    t.integer  "payment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_paid",       :default => false
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
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purchased_count",                                     :default => 0
    t.boolean  "published",                                           :default => false
    t.integer  "thumbnail_page"
    t.integer  "price"
    t.integer  "likes_count",                                         :default => 0
    t.text     "synopsis"
    t.integer  "reward_count_old",                                    :default => 0
    t.integer  "view_count",                                          :default => 0
    t.integer  "comment_count",                                       :default => 0
    t.text     "thankyou"
    t.string   "thumbnail_file_name"
    t.string   "thumbnail_file_type"
    t.integer  "thumbnail_file_size"
    t.datetime "thumbnail_updated_at"
    t.string   "thumbnail_hex_color"
    t.integer  "gallery_id"
    t.boolean  "is_external",                                         :default => false
    t.boolean  "i_own_this",                                          :default => true
    t.string   "media_type"
    t.string   "category"
    t.text     "template"
    t.string   "template_text"
    t.decimal  "reward_count",          :precision => 8, :scale => 2
    t.string   "preview_type",                                        :default => "image"
    t.string   "preview_text_template",                               :default => "watchmen"
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
    t.text     "comment"
    t.string   "state"
    t.string   "amazon_token"
    t.string   "amazon_transaction_id"
    t.string   "used_for"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",                   :limit => 128,                               :default => "",    :null => false
    t.string   "password_salt",                                                                     :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                                                     :default => 0
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
    t.boolean  "is_admin",                                                                          :default => false
    t.float    "credits",                                                                           :default => 0.0
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "stored_in_braintree",                                                               :default => false
    t.text     "tagline"
    t.string   "occupation"
    t.string   "paid_state"
    t.integer  "coins",                                                                             :default => 0
    t.datetime "subscription_last_updated_at"
    t.string   "spreedly_plan"
    t.string   "spreedly_token"
    t.integer  "subscriptions_count",                                                               :default => 0
    t.boolean  "tos_accepted",                                                                      :default => false
    t.integer  "lifetime_rewards_old",                                                              :default => 0
    t.text     "thankyou"
    t.string   "location"
    t.string   "amazon_email"
    t.integer  "impact_old",                                                                        :default => 0
    t.string   "twitter_id"
    t.string   "facebook_id"
    t.text     "twitter_friends"
    t.text     "facebook_friends"
    t.datetime "friends_last_cached_at"
    t.float    "latitude"
    t.float    "longitude"
    t.boolean  "send_reward_notification_emails",                                                   :default => true
    t.boolean  "send_digest_emails",                                                                :default => true
    t.boolean  "send_message_notification_emails",                                                  :default => true
    t.string   "i_reward_because"
    t.decimal  "impact",                                              :precision => 8, :scale => 2, :default => 0.0
    t.decimal  "lifetime_rewards",                                    :precision => 8, :scale => 2, :default => 0.0
    t.boolean  "send_new_follower_emails",                                                          :default => true
    t.boolean  "send_following_update_emails",                                                      :default => true
    t.string   "paypal_email"
    t.boolean  "send_impact_notification_emails",                                                   :default => true
    t.string   "amazon_status_code"
    t.string   "amazon_credit_instrument_id"
    t.string   "amazon_credit_sender_token_id"
    t.string   "amazon_settlement_token_id"
    t.boolean  "needs_to_reauthorize_amazon_postpaid",                                              :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

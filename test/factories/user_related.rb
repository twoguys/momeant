Factory.sequence :last_name do |n|
  "Doe#{n}"
end

Factory.define :user do |user|
  user.password               "password"
  user.password_confirmation  "password"
  user.first_name             "John"
  user.last_name              { Factory.next(:last_name) }
  user.email                  { |u| "#{u.name.delete(' ').underscore}@example.com" }
  user.subscription_last_updated_at   Time.now
  user.tos_accepted           true
end

Factory.define :creator, :parent => :user, :class => "Creator" do |creator|
  creator.amazon_email        ""
end

Factory.define :admin, :parent => :user do |admin|
  admin.is_admin              'true'
end

Factory.define :user_with_money, :parent => :user do |user|
  user.credits                500
end

Factory.define :momeant_user, :parent => :user do |user|
  user.first_name             "Momeant"
  user.last_name              ""
  user.email                  "invitations@momeant.com"
end

Factory.define :subscription do |subscription|
  subscription.user           { Factory :user }
  subscription.subscriber     { Factory :user }
end

Factory.define :user_with_coins, :parent => :user do |user|
  user.coins                  10
end

Factory.define :trial_user, :parent => :user_with_coins do |user|
  user.paid_state             "trial"
end

Factory.define :paying_user, :parent => :user_with_coins do |user|
  user.paid_state             "active_subscription"
end

Factory.define :disabled_user, :parent => :user_with_coins do |user|
  user.paid_state             "disabled_subscription"
end

Factory.define :postpaid_user, parent: :user do |user|
  user.amazon_credit_instrument_id          "I3GI53H2Q9EL2ZN9EBAJ4AFJ8YJDBUG1F82FG8H6DC7VU3TB6HT5FQ9FBZZQDBDB"
  user.amazon_credit_sender_token_id        "I1GIR3M2Q9EU2ZR9RBA237FJKYIDBSGTF8FFM8HMDZ7V13EB6TTPFQRFGZZKDPDV"
  user.amazon_settlement_token_id           "I1GII3G2QUE82ZI9DBA434FJNYZDB7G8F8JFS8HHDC7VL36B6BT3FQ9FJZZFDKD6"
  user.amazon_remaining_credit_balance      100.0
  user.needs_to_reauthorize_amazon_postpaid false
end
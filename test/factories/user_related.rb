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
  creator.amazon_email        "amazon@example.com"
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
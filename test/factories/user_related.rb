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
end

Factory.define :email_confirmed_user, :parent => :user do |user|
  user.confirmation_token     nil
  user.confirmed_at           Time.now - 1.day
end

Factory.define :creator, :parent => :email_confirmed_user, :class => "Creator" do |creator|
end

Factory.define :admin, :parent => :email_confirmed_user do |admin|
  admin.is_admin              'true'
end

Factory.define :user_with_money, :parent => :email_confirmed_user do |user|
  user.credits                500
end

Factory.define :momeant_user, :parent => :email_confirmed_user do |user|
  user.first_name             "Momeant"
  user.last_name              ""
  user.email                  "invitations@momeant.com"
end

Factory.define :subscription do |subscription|
  subscription.user           { Factory :user }
  subscription.subscriber     { Factory :user }
end

Factory.define :user_with_coins, :parent => :email_confirmed_user do |user|
  user.coins                  10
end

Factory.define :trial_user, :parent => :user_with_coins do |user|
  user.paid_state             "trial"
end
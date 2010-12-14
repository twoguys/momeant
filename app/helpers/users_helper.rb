module UsersHelper
  def subscribe_button(user)
    if current_user == user
      ""
    else
      subscription = Subscription.where(:subscriber_id => current_user.id, :user_id => user.id).first
      if subscription
        link_to("unsubscribe", user_subscription_path(user, subscription), :method => :delete, :class => 'button')
      else
        button_to("subscribe", user_subscriptions_path(user))
      end
    end
  end
end

module UsersHelper
  def subscribe_button(user)
    if current_user.is_subscribed_to?(user)
      button_to("unsubscribe", unsubscribe_from_user_path(@user))
    else
      button_to("subscribe", subscribe_to_user_path(@user))
    end
  end
end

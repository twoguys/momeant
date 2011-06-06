module UsersHelper
  def subscribe_button(user)
    if current_user.present? && current_user != user
      subscription = Subscription.where(:subscriber_id => current_user.id, :user_id => user.id).first
      if subscription
        link_to("unsubscribe", user_subscription_path(user, subscription), :method => :delete, :class => 'button')
      else
        button_to("subscribe", user_subscriptions_path(user))
      end
    end
  end
  
  def rewards_chart_series(rewards, start_time, end_time=Time.zone.now)
    rewards_by_day = rewards.where(:created_at => start_time.beginning_of_day..end_time.end_of_day)
    (start_time.to_date..Date.today).map do |date|
      rewards_on_date = rewards_by_day.find_all { |reward| reward.created_at.to_date == date }
      total_rewards = rewards_on_date.inject(0) {|sum,reward| sum + reward.amount.to_i}
      [date.to_time.to_i, total_rewards]
    end.inspect.html_safe
  end
  
  def views_chart_series(views, start_time, end_time=Time.zone.now)
    views_by_day = views.where(:created_at => start_time.beginning_of_day..end_time.end_of_day)
    (start_time.to_date..Date.today).map do |date|
      views_on_date = views_by_day.find_all { |view| view.created_at.to_date == date }.count
      [date.to_time.to_i, views_on_date]
    end.inspect.html_safe
  end
end
module ApplicationHelper
  
  def me?(user)
    current_user && current_user == user
  end
  
  def you_or_user_names(user)
    me?(user) ? "you're" : "#{user.name}'s"
  end
  
  def private_beta?
    ENV["CURRENT_RELEASE"] == "private-beta"
  end
  
  def markdown(text)
    BlueCloth.new(text).to_html.html_safe
  end
end

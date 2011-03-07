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
end

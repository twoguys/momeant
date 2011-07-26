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
  
  def link_to_active(name, url, html_options = {})
    html_options[:class] = "active" if current_page?(url)
    link_to(name, url, html_options)
  end
  
  def user_interest_links(user)
    return if user.nil?
    user.interests.map {|interest| link_to(interest.name, search_path(:query => interest.name))}.join(", ").html_safe
  end
end
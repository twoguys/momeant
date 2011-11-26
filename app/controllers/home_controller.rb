class HomeController < ApplicationController
  
  def index
    redirect_to user_path(current_user) and return if current_user

    @nav = "home"
    @background_url = "https://momeant-production.s3.amazonaws.com/assets/MomeantWallpaper0#{rand(6) + 1}.jpg"
    @hide_search = true
    render "landing"
  end
  
  def about
    @nav = "about"
    @nosidebar = true
  end
  
  def faq
    redirect_to about_path
  end

end
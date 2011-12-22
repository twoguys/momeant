class HomeController < ApplicationController
  
  def index
    @editorials = Editorial.limit(3)
    #@background_url = "https://momeant-production.s3.amazonaws.com/assets/MomeantWallpaper0#{rand(6) + 1}.jpg"
    @hide_search = true if current_user.nil?
    @nav = "home"
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
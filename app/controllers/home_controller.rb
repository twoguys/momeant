class HomeController < ApplicationController
  
  def index
    people_ids = Editorial.all.map(&:user_id).join(",")
    @people = User.where("id IN (#{people_ids})")
  end
  
  def people # ajax
    @people = User.most_rewarded.limit(50)
    render :partial => "home/person", :collection => @people, :as => :person
  end
  
  def projects # ajax
    @projects = Story.most_rewarded.published.page(params[:page]).per(6)
    @projects = @projects.where(:category => params[:category]) if params[:category]
    render :partial => "home/project", :collection => @projects, :as => :project
  end
  
  def about
    @nav = "about"
    @nosidebar = true
  end
  
  def faq
    redirect_to about_path
  end

end
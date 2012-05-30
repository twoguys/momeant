class HomeController < ApplicationController
  
  def index
    setup_landing
  end
  
  def people # ajax
    content = Story.includes(:user)
    if params[:category] == "Featured"
      content = content.published.where("user_id IN (?)", Editorial.all.map(&:user_id)).order("reward_count DESC")
    else
      content = content.published.where(:category => params[:category]).order("reward_count DESC")
    end
    @people = content.map(&:user).uniq.take(10)
    
    people_html = render_to_string :partial => "home/person", :collection => @people, :as => :person
    faces_html = render_to_string :partial => "home/faces"
    render :json => { :faces => faces_html, :people => people_html }
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
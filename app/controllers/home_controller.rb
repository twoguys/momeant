class HomeController < ApplicationController
  
  def index
    setup_landing
  end
  
  def people # ajax
    content = Story.includes(:user)
    if params[:filter] == "Popular"
      content = content.published.order("reward_count DESC")
    else
      content = content.published.where("user_id IN (?)", Editorial.all.map(&:user_id))
    end
    if params[:category].present? && params[:category] != "All"
      content = content.where(:category => params[:category])
    end
    @people = content.map(&:user).uniq.take(10)
    
    people_html = render_to_string :partial => "home/person", :collection => @people, :as => :person
    works_html = render_to_string :partial => "home/work", :collection => @people.map(&:discovery_content), :as => :content
    render :json => { :people => people_html, :works => works_html }
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
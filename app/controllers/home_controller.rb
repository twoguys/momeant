class HomeController < ApplicationController
  
  def index
    @content = ActiveSupport::OrderedHash.new
    @content["Featured"] = Story.includes(:user).published.where("id IN (?)", Editorial.all.map(&:story_id))
    Story::CATEGORIES.each do |category|
      @content[category] = Story.includes(:user).published.where(:category => category).order("reward_count DESC").limit(3)
    end
  end
  
  def people # ajax
    content = Story.includes(:user)
    if params[:category] == "Featured"
      content = content.published.where("user_id IN (?)", Editorial.all.map(&:user_id)).order("reward_count DESC")
    else
      content = content.published.where(:category => params[:category]).order("reward_count DESC")
    end
    @people = content.map(&:user).uniq.take(10)
    
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
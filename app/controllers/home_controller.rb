class HomeController < ApplicationController
  
  def index
    @people = User.where("avatar_file_name IS NOT NULL").order("lifetime_rewards DESC").limit(200)
    if @people.size < 200 # repeat if we don't have enough yet
      orig_people = @people
      ((200 / @people.size) + 1).times do
        @people += orig_people.shuffle
      end
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

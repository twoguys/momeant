class HomeController < ApplicationController
  
  def index
    @issue = LandingIssue.published.first
    if ENV["LANDING_ISSUES_ON"] == "yes" && @issue
      render "home/issues/#{@issue.position}" and return
    else
      @people = User.where("avatar_file_name IS NOT NULL").order("lifetime_rewards DESC").limit(200)
      return if @people.size == 0
      if @people.size < 200 # repeat if we don't have enough yet
        orig_people = @people
        ((200 / @people.size) + 1).times do
          @people += orig_people.shuffle
        end
      end
    end
  end
  
  def about
    @nav = "about"
    @nosidebar = true
  end
  
  def faq
    redirect_to about_path
  end

end

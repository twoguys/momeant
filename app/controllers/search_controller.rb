class SearchController < ApplicationController
  
  def index
    @content = []
    @users = []
    return if params[:query].blank?
    
    @content = Sunspot.search(Story) do
      keywords params[:query]
      with :published, true
      order_by :reward_count, :desc
    end
    @content = Kaminari.paginate_array(@content.results).page(params[:content_page]).per(6)
    
    @users = Sunspot.search(User) do
      keywords params[:query]
    end
    @users = Kaminari.paginate_array(@users.results).page(params[:users_page]).per(6)
    
    render "discovery/index"
  end
  
end
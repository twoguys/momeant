class SearchController < ApplicationController
  
  def index
    @content = []
    @creators = []
    return if params[:query].blank?
    
    @content = Sunspot.search(Story) do
      keywords params[:query]
      with :published, true
      order_by :reward_count, :desc
    end
    @content = Kaminari.paginate_array(@content.results).page(params[:content_page]).per(6)
    
    @creators = Sunspot.search(User) do
      keywords params[:query]
    end
    @creators = Kaminari.paginate_array(@creators.results).page(params[:creators_page]).per(6)
    
    render "discovery/index"
  end
  
end
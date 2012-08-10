class SearchController < ApplicationController
  
  def index
    @rewards = []
    @users = []
    return if params[:query].blank?
    
    @content = Sunspot.search(Story) do
      keywords params[:query]
      any_of do
        with :published, true
        with :published, nil
      end
      order_by :reward_count, :desc
    end
    @content = @content.results
    
    @creators = Sunspot.search(User) do
      keywords params[:query]
    end
    @creators = @creators.results
    
    render "discovery/index"
  end
  
end
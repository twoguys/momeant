class SearchController < ApplicationController
  
  def index
    @rewards = []
    @users = []
    return if params[:query].blank?
    
    @stories = Sunspot.search(Story) do
      keywords params[:query]
      any_of do
        with :published, true
        with :published, nil
      end
      order_by :reward_count, :desc
    end
    @stories = @stories.results
    
    @users = Sunspot.search(User) do
      keywords params[:query]
    end
    @users = @users.results
  end
  
end
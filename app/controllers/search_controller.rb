class SearchController < ApplicationController
  
  def index
    @rewards = []
    @users = []
    return if params[:query].blank?
    
    @search = Sunspot.search(Reward,User) do
      keywords params[:query]
    end
    @rewards = @search.results.reject{|result| !result.is_a?(Reward)}
    @users = @search.results.reject{|result| !result.is_a?(User)}
  end
  
end
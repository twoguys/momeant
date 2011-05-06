class SearchController < ApplicationController
  
  def index
    if params[:query]
      @search = Sunspot.search(Story,User) do
        keywords params[:query]
        any_of do
          with :published, true
          with :published, nil
        end
      end
      @results = @search.results
    end
  end
  
end
class HomeController < ApplicationController
  def index
    @stories = Story.all
  end
end

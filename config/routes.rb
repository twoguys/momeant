Repo::Application.routes.draw do
  
  devise_for :users

  match '/',                  :to => 'stories#index',              :as => 'home'
  root :to => "stories#index"
end

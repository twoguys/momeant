Repo::Application.routes.draw do
  
  devise_for :users, :controllers => { :registrations => "registrations" }
  
  resources :invitations do
    collection do
      get :invite_creator
    end
  end
  match 'invites/:token',       :to => 'invitations#accept',        :as => :accept_invitation
  
  resources :stories do
    member do
      get :preview
      get :purchase
      get :bookmark
    end
    get :bookmarked, :on => :collection
  end
  match '/library',             :to => 'stories#library',           :as => :library
  
  resources :deposits

  match '/',                    :to => 'home#index',                :as => :home
  root :to => "home#index"
  
end

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
      post :purchase
      post :bookmark
      delete :unbookmark
      post :recommend
      delete :unrecommend
    end
    get :bookmarked, :on => :collection
    get :recommended, :on => :collection
    get :render_page_theme, :on => :collection
  end
  
  resources :deposits
  
  resources :users do
    resources :subscriptions
  end
  
  namespace :admin do
    match '/', :to =>"dashboard#index", :as => :dashboard
    resources :pay_periods do
      post :mark_paid, :on => :member
    end
  end
  
  match '/library',             :to => 'users#library',             :as => :library
  match '/',                    :to => 'home#index',                :as => :home
  root :to => "home#index"
  
end

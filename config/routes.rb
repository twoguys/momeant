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
      post :unbookmark
      post :recommend
      post :unrecommend
    end
    get :bookmarked, :on => :collection
    get :recommended, :on => :collection
  end
  match '/library',             :to => 'stories#library',           :as => :library
  
  resources :deposits
  
  resources :users do
    post :subscribe_to, :on => :member
    post :unsubscribe_from, :on => :member
  end
  
  namespace :admin do
    match '/', :to =>"dashboard#index", :as => :dashboard
    resources :pay_periods do
      post :mark_paid, :on => :member
    end
  end

  match '/',                    :to => 'home#index',                :as => :home
  root :to => "home#index"
  
end

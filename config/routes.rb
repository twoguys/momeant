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
      post :like
      delete :unlike
      delete :remove_tag_from
      post :publish
      put :autosave
      post :add_topic_to
      post :remove_topic_from
    end
    get :bookmarked, :on => :collection
    get :recommended, :on => :collection
    get :render_page_theme, :on => :collection
    get :tagged_with, :on => :collection
    get :search, :on => :collection
    get :random, :on => :collection
    
    resources :pages, :only => [:create, :update, :destroy] do
      post :add_or_update_image, :on => :member
    end
  end
  match "/stories/tagged_with/:tag",    :to => "stories#tagged_with",  :as => :stories_tagged_with
  
  match "/topics/:name", :to => "topics#show", :as => :topic
  
  match '/credits', :to => "deposits#index", :as => :credits
  match '/credits/buy', :to => "deposits#create", :as => :deposit
  
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

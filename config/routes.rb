Repo::Application.routes.draw do
  
  devise_for :users, :controllers => {
    :registrations => "registrations",
    :sessions => "sessions",
    :passwords => "passwords"
  }
  
  # resources :invitations do
  #   collection do
  #     get :invite_creator
  #   end
  # end
  # match 'invites/:token',       :to => 'invitations#accept',        :as => :accept_invitation
  
  resources :stories do
    member do
      get :preview
      post :bookmark
      delete :unbookmark
      delete :remove_tag_from
      post :publish
      put :autosave
      post :add_topic_to
      post :remove_topic_from
      post :update_thumbnail
      post :change_to_external
      post :change_to_creator
    end
    collection do
      get :bookmarked
      get :recommended
      get :render_page_form
      get :render_page_theme
      get :tagged_with
      get :search
      get :random
      get :recent
      get :most_rewarded
    end
    
    resources :pages, :only => [:create, :update, :destroy] do
      post :add_or_update_image, :on => :member
    end
    
    resources :curations
  end
  match "/stories/tagged_with/:tag",    :to => "stories#tagged_with",  :as => :stories_tagged_with
  
  match "/topics/:name", :to => "topics#show", :as => :topic
  
  match '/credits', :to => "deposits#index", :as => :credits
  match '/credits/buy', :to => "deposits#create", :as => :deposit
  
  resources :users do
    resources :subscriptions
    resources :rewards
    resources :galleries
    get :bookmarks
    
    member do
      get :stream
      get :creations
      get :rewarded
      get :patrons
      get :followers
      get :following
    end
    
    # Homepage tab
    get :top_curators, :on => :collection

    # Spreedly updates come here
    post :billing_updates, :on => :collection
  end
  match '/analytics',           :to => "users#analytics",           :as => :analytics
  match '/community',           :to => "users#community",           :as => :community
  match '/community/creators',  :to => "users#community_creators",  :as => :community_creators
  
  namespace :admin do
    match '/', :to =>"dashboard#index", :as => :dashboard
    match '/live', :to => "dashboard#live", :as => :live
    match '/users', :to => "dashboard#users", :as => :admin_users
    resources :pay_periods do
      post :mark_paid, :on => :member
    end
    resources :invitations
    resources :adverts do
      post :toggle_enabled, :on => :member
    end
  end
  
  match '/search',              :to => "search#index",              :as => :search
  match '/subscribe',           :to => 'home#subscribe',            :as => :subscribe
  match '/invite',              :to => 'home#invite',               :as => :invite
  match '/apply',               :to => 'home#apply',                :as => :apply
  match '/about',               :to => 'home#about',                :as => :about
  match '/thankyou',            :to => 'home#thankyou',             :as => :thankyou
  match '/faq',                 :to => 'home#faq',                  :as => :faq
  match '/tos',                 :to => 'home#tos',                  :as => :tos
  match '/privacy',             :to => 'home#privacy',              :as => :privacy

  match '/',                    :to => 'home#index',                :as => :home
  match '/global',              :to => 'home#global',               :as => :global
  match '/following',           :to => 'home#following',            :as => :following
  root :to => "home#index"
  
end

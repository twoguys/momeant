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
    end
    get :bookmarked, :on => :collection
    get :recommended, :on => :collection
    get :render_page_form, :on => :collection
    get :render_page_theme, :on => :collection
    get :tagged_with, :on => :collection
    get :search, :on => :collection
    get :random, :on => :collection
    
    resources :pages, :only => [:create, :update, :destroy] do
      post :add_or_update_image, :on => :member
    end
    
    resources :rewards
    resources :curations
  end
  match "/stories/tagged_with/:tag",    :to => "stories#tagged_with",  :as => :stories_tagged_with
  
  match "/topics/:name", :to => "topics#show", :as => :topic
  
  match '/credits', :to => "deposits#index", :as => :credits
  match '/credits/buy', :to => "deposits#create", :as => :deposit
  
  resources :users do
    resources :subscriptions

    # Spreedly updates come here
    post :billing_updates, :on => :collection
  end
  
  namespace :admin do
    match '/', :to =>"dashboard#index", :as => :dashboard
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
  match '/thankyou',            :to => 'home#thankyou',             :as => :thankyou
  match '/faq',                 :to => 'home#faq',                  :as => :faq
  match '/',                    :to => 'home#index',                :as => :home
  root :to => "home#index"
  
end

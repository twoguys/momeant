Repo::Application.routes.draw do
  
  devise_for :users, :controllers => {
    :registrations => "registrations",
    :sessions => "sessions",
    :passwords => "passwords"
  }
  
  resources :stories do
    member do
      delete :remove_tag_from
      post :publish
      put :autosave
      post :update_thumbnail
      post :change_to_external
      post :change_to_creator
      put :choose_media_type
      get :cropper
      post :crop
    end
    collection do
      get :render_page_form
      get :render_page_theme
      get :tagged_with
      get :search
    end
    
    resources :pages, :only => [:create, :update, :destroy] do
      post :add_or_update_image, :on => :member
    end
  end
  
  match '/coins', :to => "amazon_payments#index", :as => :coins
  match '/coins/buy', :to => "amazon_payments#create", :as => :buy_coins
  match '/coins/accept', :to => "amazon_payments#accept", :as => :accept_coins
  
  resources :users do
    resources :subscriptions, :only => [:create] do
      collection do
        post :unsubscribe
      end
    end
    match '/subscriptions/filter', :to => "subscriptions#filter"
    resources :rewards
    resources :cashouts do
      put :update_amazon_email, :on => :collection
    end
    resources :galleries do
      get :move_up, :on => :member
      get :move_down, :on => :member
      post :update_description, :on => :collection
    end
    resources :messages do
      collection do
        post :public
      end
    end
    resources :broadcasts, :only => [:create]
    resources :comments, :only => [:create]
    
    member do
      get :settings
      post :update_in_place
      post :update_avatar
      post :update_email_setting
      get :activity
      get :more_activity #ajax
    end
    
    # Feedback
    post :feedback, :on => :collection
  end
  match '/users/:id/content_rewarded_by/:rewarder_id', :to => "users#content_rewarded_by", :as => :user_content_rewarded_by
  match '/rewards/:id/visualize', :to => "rewards#visualize",           :as => :visualize_reward
  
  match '/share/twitter_form',    :to => "sharing#twitter_form"
  match '/share/facebook_form',   :to => "sharing#facebook_form"
  match '/share/twitter',         :to => "sharing#twitter",             :as => :share_twitter
  match '/share/facebook',        :to => "sharing#facebook",            :as => :share_facebook
  
  match '/discover',              :to => "discovery#index",                :as => :discovery
  match '/content/recommended',   :to => "discovery#recommended_content",  :as => :recommended_content
  match '/content/popular',       :to => "discovery#popular_content",      :as => :popular_content
  match '/content/nearby',        :to => "discovery#nearby_content",       :as => :nearby_content
  match '/content/newest',        :to => "discovery#newest_content",       :as => :newest_content
  match '/people/notable',        :to => "discovery#notable_people",       :as => :notable_people
  match '/people/friends',        :to => "discovery#friends_people",       :as => :friends_people
  match '/people/friends/reload', :to => "discovery#reload_friends_people",:as => :reload_friends_people
  match '/people/friends/reload_full', :to => "discovery#reload_friends_activity",:as => :reload_friends_activity
  match '/people/creators',       :to => "discovery#creators_people",      :as => :creators_people
  match '/people/patrons',        :to => "discovery#patrons_people",       :as => :patrons_people
  
  match '/subscriptions',         :to => "subscriptions#index",         :as => :subscriptions
  
  namespace :admin do
    match '/', :to =>"dashboard#index", :as => :dashboard
    match '/live', :to => "dashboard#live", :as => :live
    match '/users', :to => "dashboard#users", :as => :users
    resources :pay_periods do
      post :mark_paid, :on => :member
    end
    resources :invitations
    resources :adverts do
      post :toggle_enabled, :on => :member
    end
    resources :editorials
  end
  
  match '/auth/:provider/configure' => 'authentications#configure'
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/:provider/check' => 'authentications#check'
  
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
  match '/people',              :to => 'home#people',               :as => :more_people
  match '/projects',            :to => 'home#projects',             :as => :more_projects
  root :to => "home#index"
  
end

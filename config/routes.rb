Repo::Application.routes.draw do
  
  devise_for :users
  devise_scope :user do
    post '/creators/signup' => "registrations#creator", :as => :creator_signup # creator signup 1 submit
    post '/creators/login'  => "sessions#creator",      :as => :creator_login
    post '/users/sign_in_remote' => "sessions#remote"
  end
  # creator signup 1
  match '/creators', :to => "users#creators", :as => :creators
  # creator signup 2 and 2 submit
  match '/users/:id/creator-info', :to => "users#creator_info", :as => :creator_info
  # creator signup 3 and 3 submit
  match '/users/:id/creator-payment', :to => "users#creator_payment", :as => :creator_payment
  
  resources :stories do
    member do
      delete :remove_tag_from
      post :publish
      get :share
      put :autosave
      post :update_thumbnail
      post :change_to_external
      post :change_to_creator
      get :cropper
      post :crop
      get :preview
      get :reward
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
  match '/before-creation', to: "stories#before", as: :before_creation
  
  match '/coins', :to => "amazon_payments#index", :as => :coins
  match '/payments', :to => "users#fund_pledged_rewards", :as => :fund_rewards
  match '/payments/start-postpaid', to: "amazon_payments#start_postpaid", as: :start_amazon_postpaid
  match '/payments/accept-postpaid', to: "amazon_payments#accept_postpaid", as: :accept_amazon_postpaid
  match '/payments/pay', :to => "amazon_payments#create", :as => :pay_for_rewards
  match '/payments/accept', :to => "amazon_payments#accept", :as => :accept_payment
  match '/amazon/update_status', to: "amazon_payments#update_status"
  
  resources :users do
    resources :subscriptions, :only => [:create] do
      collection do
        post :unsubscribe
      end
    end
    resources :rewards
    resources :cashouts do
      put :update_amazon_email, :on => :collection
    end
    resources :galleries do
      get :move_up, :on => :member
      get :move_down, :on => :member
      post :update_description, :on => :collection
    end
    resources :broadcasts, :only => [:create]
    resources :comments, :only => [:create]
    resources :thank_you_levels
    
    member do
      get :settings
      post :submit_creator_request
      post :update_in_place
      post :update_avatar
      post :update_email_setting
      post :change_password
      get :thankyous
    end
    
    collection do
      get 'become-a-creator', :action => :become_a_creator, :as => :become_a_creator
    end
    
    # Feedback
    post :feedback, :on => :collection
  end
  match '/users/:id/content_rewarded_by/:rewarder_id', :to => "users#content_rewarded_by", :as => :user_content_rewarded_by
  match '/rewards/:id/visualize', :to => "rewards#visualize",           :as => :visualize_reward
  
  # OLD user routes
  match "/users/:id/patronage" => redirect("/users/%{id}")
  
  resources :discussions
  
  resources :messages do
    get :user_lookup, on: :collection
  end
  
  match '/share/twitter_form',    :to => "sharing#twitter_form"
  match '/share/facebook_form',   :to => "sharing#facebook_form"
  match '/share/twitter',         :to => "sharing#twitter",             :as => :share_twitter
  match '/share/facebook',        :to => "sharing#facebook",            :as => :share_facebook
  
  match '/discover',              to: "discovery#index",                as: "discovery"
  match '/discover/creators',     to: "discovery#creators"
  match '/discover/content',      to: "discovery#content"
  
  match '/feed',                  :to => "subscriptions#index",            :as => :subscriptions
  match '/feed/work',             to: "subscriptions#work",                as: "subscriptions_work"
  match '/feed/rewards',          to: "subscriptions#rewards",             as: "subscriptions_rewards"
  match '/feed/discussions',      to: "subscriptions#discussions",         as: "subscriptions_discussions"
  match '/feed/user/:user_id',    to: "subscriptions#user",                as: "subscriptions_user"
  
  namespace :admin do
    match '/', :to =>"dashboard#index", :as => :dashboard
    match '/live', :to => "dashboard#live", :as => :live
    match '/users', :to => "dashboard#users", :as => :users
    match '/users/:id/change_to', :to => "dashboard#change_user_to"
    resources :pay_periods do
      get :unpaid, on: :collection
      post :mark_line_item_as_paid, :on => :collection
    end
    resources :invitations
    resources :adverts do
      post :toggle_enabled, :on => :member
    end
    resources :editorials
    resources :landing_issues do
      get :preview, on: :member
    end
    resources :emails, only: [:new, :create]
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

  root :to => "home#index"
  
end

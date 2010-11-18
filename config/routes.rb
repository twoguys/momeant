Repo::Application.routes.draw do
  
  devise_for :users, :controllers => { :registrations => "registrations" }
  
  resources :invitations do
    collection do
      get :invite_creator
    end
  end
  match 'invites/:token',       :to => 'invitations#accept',          :as => :accept_invitation
  
  resources :stories do
    member do
      get :preview
    end
  end

  match '/',                    :to => 'home#index',               :as => 'home'
  root :to => "home#index"
  
end

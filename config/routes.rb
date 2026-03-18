Rails.application.routes.draw do
  # Dashboard redirect
  get "dashboard", to: "dashboard#index", as: :dashboard

  resources :blog, only: [ :index, :show ], controller: "blog"
  resources :donations, only: [ :new, :create ] do
    collection do
      get :thank_you
    end
  end

  # Admin namespace
  namespace :admin do
    get "dashboard", to: "dashboard#index"
    resources :directorates
    resources :states
    resources :users
    resources :events
    resources :trainings do
      resources :training_sessions
    end
    resources :blog_posts
    resources :donations
    resources :pages
  end



  # State namespace
  namespace :states do
    get "dashboard", to: "dashboard#index"
    resource :state, only: [ :show ]
  end

  # Directorate namespace
  namespace :directorates do
    get "dashboard", to: "dashboard#index"
    resources :reports, only: [ :index, :show ] do
      member do
        patch :review
        patch :approve
      end
    end
  end

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  resources :reports do
    member do
      patch :submit
    end
  end

  resources :trainings, only: [ :index, :show ] do
    resources :training_sessions, only: [ :show ], path: "sessions"
  end

  resources :events, only: [ :index, :show ] do
    resources :registrations, only: [ :create, :destroy ]
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Public pages
  root "home#index"

  # CMS Pages with named routes to maintain helpers
  get "about", to: "pages#about"
  get "contact", to: "pages#show", defaults: { slug: "contact" }

  # Catch-all for other CMS pages (Must be the last route)
  get ":slug", to: "pages#show", as: :page
end

Rails.application.routes.draw do
  # Dashboard redirect
  get "dashboard", to: "dashboard#index", as: :dashboard
  resource :profile, only: [ :show, :edit, :update ]

  resources :blog, only: [ :index, :show ], controller: "blog"
  resources :donations, only: [ :new, :create ] do
    collection do
      get :thank_you
    end
  end

  # Admin namespace
  namespace :admin do
    get "dashboard", to: "dashboard#index"
    resources :countries
    resources :directorates
    resources :zones
    resources :states do
      resources :areas
    end
    resources :users do
      member do
        patch :reset_password
      end
    end
    resources :events do
      member do
        patch :deduplicate_camp_details
      end
    end
    resources :trainings do
      resources :training_sessions
    end
    resources :blog_posts
    resources :donations
    resources :contact_messages, path: "messages", only: [ :index, :show, :destroy ] do
      member do
        patch :mark_read
      end
    end
    resources :pages
    resources :announcements
  end



  # State namespace
  namespace :states do
    get "dashboard", to: "dashboard#index"
    resource :state, only: [ :show ] do
      resources :areas
    end
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
    registrations: "users/registrations",
    passwords: "users/passwords"
  }

  resources :reports do
    member do
      patch :submit
    end
  end
  resources :internal_messages, path: "messages", only: [ :index, :show, :new, :create ]

  resources :trainings, only: [ :index, :show ] do
    resources :training_registrations, only: [ :create ], path: "registrations"
    resources :training_sessions, only: [ :show ], path: "sessions"
  end

  resources :events, only: [ :index, :show ] do
    resources :registrations, only: [ :create, :show, :destroy ]
  end

  resources :announcements, only: [ :show ]

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA files
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Public pages
  root "home#index"
  get "search", to: "home#search", as: :search

  # CMS Pages with named routes to maintain helpers
  get "about", to: "pages#about"
  get "programmes", to: "pages#programmes", as: :programmes
  get "contact", to: "pages#contact", as: :contact
  post "contact", to: "contact_messages#create"
  get "privacy", to: "pages#show", defaults: { slug: "privacy" }, as: :privacy
  get "terms", to: "pages#show", defaults: { slug: "terms" }, as: :terms

  # Catch-all for other CMS pages (Must be the last route)
  get ":slug", to: "pages#show", as: :page
end

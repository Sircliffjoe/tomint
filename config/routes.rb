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
    resource :maintenance, only: [ :show, :update ] do
      post :toggle, on: :member
    end

    # TOM ASK Admin
    namespace :ask do
      get "/", to: "dashboard#index", as: :dashboard
      resources :questions do
        member do
          patch :moderate
          post :approve_public
          post :reject
          post :flag_safeguarding
          post :assign
          post :close
          post :reopen
        end
        resources :responses, only: [ :create, :update, :destroy ] do
          member do
            post :publish
            post :send_private
          end
        end
        resources :internal_notes, only: [ :create, :destroy ]
      end
      resources :safeguarding, only: [ :index, :show ] do
        member do
          post :escalate
          patch :update_status
        end
        resources :escalations, only: [ :update, :destroy ]
      end
      resources :live_sessions, path: "live" do
        member do
          post :start
          post :pause
          post :end
          get :moderation
          get :qr_code
          post "questions/:question_id/approve", to: "live_sessions#approve_question", as: :approve_question
          post "questions/:question_id/reject", to: "live_sessions#reject_question", as: :reject_question
          post "questions/:question_id/pin", to: "live_sessions#pin_question", as: :pin_question
          post "questions/:question_id/unpin", to: "live_sessions#unpin_question", as: :unpin_question
          post "questions/:question_id/mark_answered", to: "live_sessions#mark_question_answered", as: :mark_question_answered
        end
      end
      resources :categories
      get "analytics", to: "analytics#index"
      resource :settings, only: [ :show, :update ]
    end
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

  # TOM ASK Public Experience
  scope :ask, as: :ask, module: :ask do
    root to: "home#index"
    post "questions", to: "home#create", as: :submit_question
    get "confirmation/:reference", to: "home#confirmation", as: :confirmation
    get "check", to: "home#status_check", as: :status_check

    resources :questions, only: [ :index, :show ]

    get "live", to: "live#index", as: :live_index
    get "live/:slug", to: "live#show", as: :live_session
    get "live/:slug/display", to: "live#display", as: :live_display
    post "live/:slug/questions", to: "live#create_question", as: :live_create_question
    post "live/:slug/questions/:id/vote", to: "live#vote", as: :live_vote_question
  end

  # Catch-all for other CMS pages (Must be the last route)
  get ":slug", to: "pages#show", as: :page
end

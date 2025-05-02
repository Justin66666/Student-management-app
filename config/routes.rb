Rails.application.routes.draw do
  # Devise routes for authentication
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords'
  }

  # Root route
  root 'home#index'

  # Course routes
  resources :courses, only: [:index, :show]

  # Recommendation letters
  resources :recommendation_letters, only: [:new, :create, :show]

  # Admin routes
  namespace :admin do
    get 'courses/reload', to: 'courses#reload'
    post 'courses/reload', to: 'courses#reload'
    
    # 独立的应用程序管理路由
    resources :applications, only: [:index, :show, :edit, :update] do
      member do
        patch :approve
        patch :reject
      end
    end
    
    resources :courses do
      resources :applications, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    end
    
    resources :users do
      member do
        patch :approve
      end
    end
    
    resources :recommendation_letters, only: [:index, :show, :edit, :update, :destroy]
    
    # Grader assignment routes
    resources :grader_assignments, only: [:index] do
      collection do
        patch :assign_grader
        patch :unassign_grader
        patch :update_graders_required
      end
    end
  end

  # Student routes
  namespace :student do
    resources :applications, only: [:index, :new, :create, :show, :destroy, :edit, :update]
  end

  # Instructor routes
  namespace :instructor do
    resources :courses, only: [:index, :show] do
      resources :applications, only: [:show]
      resources :sections, only: [:show] do
        resources :graders, only: [:index]
      end
      resources :recommendation_letters, only: [:new, :create, :index]
    end
    resources :recommendation_letters, only: [:index]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end

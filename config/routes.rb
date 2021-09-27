Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: "unauthenticated/confirmations",
    passwords: "unauthenticated/passwords",
    registrations: "unauthenticated/registrations",
    sessions: "unauthenticated/sessions",
  }
  root to: "home#index"

  resources :institutions, only: [:index, :new, :create]
  resources :states, only: [:index]
  resources :visits, only: [:new, :create]
  resources :projects, only: [:index]
  resources :reserves, only: [:index, :show] do
    resources :amenities, only: [:index]
    resource :reserve_inputs, only: [:show]
    resource :calendar, only: [:show]
    resources :waivers, only: [:index]
    resource :rules_and_regulations, only: [:show]
  end

  namespace :visits do
    resources :reserve_inputs, only: [:show]
    resources :amenities, only: [:index]
  end
end

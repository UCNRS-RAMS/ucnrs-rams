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

  namespace :visits do
    resources :reserve_inputs, only: [:show]
    resources :amenities, only: [:index]
  end
end

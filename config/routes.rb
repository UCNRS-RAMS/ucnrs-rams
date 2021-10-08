Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: "unauthenticated/confirmations",
    passwords: "unauthenticated/passwords",
    registrations: "unauthenticated/registrations",
    sessions: "unauthenticated/sessions",
  }
  root to: "home#index"

  resources :institutions, only: [:index, :new, :create]
  resources :reserves, only: [] do
    resources :amenities, only: [:index]
    resource :reserve_inputs, only: [:show]
  end
  resources :states, only: [:index]
  resources :visits, only: [:new, :create]
end

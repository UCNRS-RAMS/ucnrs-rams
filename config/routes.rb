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

  resources :projects, only: [:index, :new, :create] do
    resource :teams, only: [:edit, :update], controller: "projects/teams"
  end

  resources :reserves, only: [:index, :show] do
    resources :amenities, only: [:index], controller: "reserves/amenities"
    resource :reserve_inputs, only: [:show], controller: "reserves/reserve_inputs"
    resource :calendar, only: [:show], controller: "reserves/calendar"
    resources :waivers, only: [:index], controller: "reserves/waivers"
    resource :rules_and_regulations, only: [:show], controller: "reserves/rules_and_regulations"
    resources :more_information, only: [:index], controller: "reserves/addendums"
  end

  namespace :visits do
    resources :reserve_inputs, only: [:show]
    resources :amenities, only: [:index]
    resources :projects, only: [:index]
    resources :reserves, only: [:index]
  end
end

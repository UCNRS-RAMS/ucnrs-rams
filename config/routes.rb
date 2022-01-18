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
  resources :users, only: [:index]

  resources :team_memberships, only: [:edit, :update], controller: "projects/team_memberships"
  resources :fundings, only: [:edit, :update], controller: "projects/fundings"
  resources :projects, only: [:index, :new, :create, :show] do
    resources :team_memberships, only: [:index, :create, :destroy], controller: "projects/team_memberships"
    resources :users, only: [:new, :create], controller: "projects/users"
    resources :permits, only: [:index], controller: "projects/permits"
    resources :permit_answers, only: [:create], controller: "projects/permit_answers"
    resources :fundings, only: [:index, :create], controller: "projects/fundings"
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
  devise_scope :user do 
    resources :password, only: [:new, :create]
  end
end

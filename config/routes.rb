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
  resources :users, only: [:index]

  resources :team_memberships, only: [:edit, :update, :destroy], controller: "projects/team_memberships"
  resources :fundings, only: [:edit, :update, :destroy], controller: "projects/fundings"
  resources :projects, only: [:index, :new, :create, :show, :edit, :update] do
    resources :team_memberships, only: [:index, :create], controller: "projects/team_memberships"
    resources :users, only: [:new, :create], controller: "projects/users"
    resources :questions, only: [:index], controller: "projects/questions"
    resources :answers, only: [:create], controller: "projects/answers"
    resources :fundings, only: [:index, :create], controller: "projects/fundings"
    resource :complete, only: [:update], controller: "projects/complete"
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
    resources :units, only: [:index]
    resources :projects, only: [:index]
    resources :reserves, only: [:index]
  end
  resources :visits, only: [:new, :create, :show] do
    get :amenity_booking, on: :new
  end

  devise_scope :user do
    resources :password, only: [:new, :create]
  end

  namespace :manager do
    resources :reserves, only: [:show] do
      resources :team_memberships, only: [:edit, :update, :destroy], controller: "projects/team_memberships"
      resource :dashboard, only: [:show]
      resources :projects, only: [:index, :show] do
        resource :summary, only: [:show], controller: "projects/summary"
        resource :detail, only: [:edit, :update], controller: "projects/detail"
        resource :permit, only: [:edit, :create], controller: "projects/permit"
        resources :fundings, except: [:show], controller: "projects/fundings"
        resources :visits, only: [:index], controller: "projects/visits"
        resources :team_memberships, only: [:index, :create], controller: "projects/team_memberships"
        resources :users, only: [:new, :create], controller: "projects/users"
        resources :activity_and_notes, only: [:index, :create, :show], controller: "projects/activity_and_notes"
      end
      resources :reports, only: [:show] do
        get "report_part_1", on: :member
        get "report_part_2", on: :member
        get "report_part_3", on: :member
        get "report_part_4", on: :member
        get "report_part_5", on: :member
        get "report_part_6", on: :member
        get "report_part_7", on: :member
        get "report_part_8", on: :member
      end
      namespace :reserve_info do
        resource :reserve_details, only: [:edit, :update]
        resources :amenities_and_rates, only: [:index]
        resources :waivers, only: [:index]
        resource :rules_and_regulations, only: [:edit, :update]
        resources :permits, only: [:index]
        resources :reserve_questions, only: [:index]
        resources :staff_and_notifications, only: [:index]
      end
    end
  end
end

Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: "unauthenticated/confirmations",
    passwords: "unauthenticated/passwords",
    registrations: "unauthenticated/registrations",
    sessions: "unauthenticated/sessions",
  }
  root to: "dashboard#index"

  resources :dashboard, only: [:index]
  resources :home, only: [:index]

  namespace :home do
    resource :calendar, only: [:show], controller: "calendar"
    resources :latest_news, only: [:index]
  end

  resources :institutions, only: [:index, :new, :create]
  resources :states, only: [:index]
  resources :countries, only: [] do
    resources :states, only: [:index], controller: "countries/states"
  end
  resources :users, only: [:index]

  resources :team_memberships, only: [:edit, :update, :destroy],
    controller: "projects/team_memberships"
  resources :fundings, only: [:edit, :update, :destroy], controller: "projects/fundings"
  resources :projects, only: [:index, :new, :create, :show, :edit, :update] do
    post :contact_manager

    resources :team_memberships, only: [:index, :create], controller: "projects/team_memberships"
    resources :users, only: [:new, :create], controller: "projects/users"
    resources :questions, only: [:index], controller: "projects/questions"
    resources :answers, only: [:create], controller: "projects/answers"
    resources :fundings, only: [:index, :create], controller: "projects/fundings"
    resource :complete, only: [:update], controller: "projects/complete"
    resource :file_upload, only: [:update], controller: "projects/file_upload"
  end

  namespace :reserves do
    resources :project_types, only: [:index]
    resources :contact_reserves, only: [:index]
  end

  resources :reserves, only: [:index, :show] do
    resources :amenities, only: [:index], controller: "reserves/amenities"
    resource :reserve_inputs, only: [:show], controller: "reserves/reserve_inputs"
    resource :calendar, only: [:show], controller: "reserves/calendar" do
      resources :visits, only: [:index, :show], controller: "reserves/calendar/visits"
    end
    resources :waivers, only: [:index], controller: "reserves/waivers"
    resource :rules_and_directions, only: [:show], controller: "reserves/rules_and_directions"
    resources :more_information, only: [:index], controller: "reserves/addendums"
  end

  namespace :visits do
    resources :reserve_inputs, only: [:show]
    resources :amenities, only: [:index]
    resources :units, only: [:index]
    resources :projects, only: [:index]
    resources :reserves, only: [:index]
  end

  resources :user_visits, only: [:edit, :update, :destroy], controller: "visits/user_visits"
  resources :visits, only: [:new, :create, :show, :edit, :update] do
    get :amenity_booking, on: :new
    put :cancel, on: :member
    resources :user_visits, only: [:new, :index, :create, :destroy],
      controller: "visits/user_visits"
    resources :questions, only: [:index], controller: "visits/questions"
    resources :answers, only: [:create], controller: "visits/answers"
    resource :waivers_policies, only: [:show, :update], controller: "visits/waivers_policies"
    resource :project, only: [] do
      resources :team_memberships, only: [:index, :create],
        controller: "visits/project/team_memberships"
    end
  end

  devise_scope :user do
    resources :password, only: [:new, :create]
  end

  resource :helps, only: [:show]
  resource :get_zotero_publication_count, only: [:show]
  resources :invoices, only: [:show]

  namespace :manager, namespace: :manager do
    resources :amenities, only: [:index]

    namespace :visits do
      resources :projects, only: [:index]
    end

    resources :reserves, only: [:show] do
      resources :new_features, only: [:index]
      resources :team_memberships, only: [:edit, :update, :destroy],
        controller: "projects/team_memberships"
      resource :dashboard, only: [:show], controller: "dashboard" do
        resources :visits, only: [:index], controller: "dashboard/visits"
        resource :calendar, only: [:show], controller: "dashboard/calendar" do
          resources :visits, only: [:index, :show], controller: "dashboard/calendar/visits"
        end
      end

      resources :invoices, only: [:index] do
        resource :email, only: [:new, :create], controller: "invoices/emails"
        resource :pdf, only: [:show], controller: "invoices/pdf"
      end

      resources :uninvoiced, only: [:index]
      resources :projects do
        resources :questions, only: [:index], controller: "projects/questions"
        resources :answers, only: [:create], controller: "projects/answers"
        resources :fundings, only: [:index, :create], controller: "projects/fundings"
        resource :complete, only: [:update], controller: "projects/complete"
        resource :summary, only: [:show], controller: "projects/summary"
        resource :detail, only: [:edit, :update], controller: "projects/detail"
        resource :permit, only: [:edit, :create], controller: "projects/permit"
        resources :fundings, except: [:show], controller: "projects/fundings"
        resources :visits, only: [:index], controller: "projects/visits"
        resources :team_memberships, only: [:index, :create],
          controller: "projects/team_memberships"
        resources :users, only: [:new, :create], controller: "projects/users"
        resources :activity_and_notes, only: [:index, :create],
          controller: "projects/activity_and_notes"
        resources :logs, only: [:show], controller: "projects/logs"
      end

      resources :user_visits, only: [:edit, :update], controller: "visits/user_visits"
      resources :visits do
        resources :user_visits, only: [:new, :index, :create, :destroy],
          controller: "visits/user_visits"
        resources :questions, only: [:index], controller: "visits/questions"
        resources :answers, only: [:create], controller: "visits/answers"
        resource :waivers_policies, only: [:show, :update], controller: "visits/waivers_policies"
        resources :invoices, except: [:index] do
          resources :payments, controller: "invoices/payments"
        end

        resource :amenity_visits, only: [:update], controller: "visits/amenity_visits"
        resource :summary, only: [:edit, :update, :show], controller: "visits/summary"
        resource :detail, only: [:edit, :update], controller: "visits/detail"
        resources :activity_and_notes, only: [:index, :create],
          controller: "visits/activity_and_notes"
        resources :logs, only: [:show], controller: "visits/logs"
        resources :reserve_info, only: [:index, :create], controller: "visits/reserve_info"
        resources :invoices, only: [:index], as: "invoice", controller: "visits/invoices"
      end

      namespace :reports do
        resources :flex, only: [:index]
      end

      resources :reports, only: [:show, :update] do
        get "report_part_1", on: :member
        get "report_part_2", on: :member
        get "report_part_3", on: :member
        get "report_part_4", on: :member
        get "report_part_5", on: :member
        get "report_part_6", on: :member
        get "report_part_7", on: :member
        get "report_part_8", on: :member
        get "report_part_9", on: :member
      end

      namespace :reserve_info do
        resource :reserve_tags, only: [:create, :new]
        resource :reserve_details, only: [:edit, :update]
        resources :amenities_and_rates, only: [:index]
        resources :amenity_rates, only: [:edit, :update],
          controller: "amenities_and_rates/amenity_rates"
        resources :amenities, only: [:new, :create, :edit, :update],
          controller: "amenities_and_rates/amenities"
        resources :amenity_rate_categories, only: [:new, :create, :edit, :update],
          controller: "amenities_and_rates/amenity_rate_categories"
        resources :waivers, only: [:index, :edit, :update, :new, :create]
        resource :rules_and_regulations, only: [:edit, :update]
        resource :directions, only: [:edit, :update]
        resources :permits, only: [:index, :edit, :update]
        resources :reserve_questions, only: [:index, :new, :create, :edit, :update]
        resources :staff_and_notifications
        resources :reserve_addendums
      end

      resources :users, only: [:index, :edit, :update] do
        resources :activities, only: [:index], controller: "users/activities"
      end

      resources :institutions, only: [:index, :edit, :update]
      resources :search, only: [:index]
    end
  end

  namespace :admin do
    resources :reports, only: [:index]
    resources :new_features
  end
end

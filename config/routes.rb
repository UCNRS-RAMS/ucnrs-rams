Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "unauthenticated/sessions",
    passwords: "unauthenticated/passwords",
    registrations: "unauthenticated/registrations",
  }
  root to: "home#index"
end

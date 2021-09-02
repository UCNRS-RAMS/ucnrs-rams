Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "unauthenticated/sessions",
    passwords: "unauthenticated/passwords",
  }
  root to: "home#index"
end

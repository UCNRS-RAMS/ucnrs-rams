Rails.application.routes.draw do
  devise_for :users, controllers: {
    passwords: "unauthenticated/passwords"
  }
  root to: "home#index"
end

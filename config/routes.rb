Rails.application.routes.draw do


  root to: 'home#index'

  resources :sessions, only: [:new, :create]
  delete "sessions", to: "sessions#destroy", as: :sign_out
  get    "sessions/two_factor_required"
  post   "sessions/two_factor_verification"

  get 'two_factor_authentication/setup'
  match 'two_factor_authentication/verify', via: [:get, :post]
  post 'two_factor_authentication/register'

end

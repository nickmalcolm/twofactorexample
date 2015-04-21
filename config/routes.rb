Rails.application.routes.draw do

  root to: 'home#index'
  resources :sessions, only: [:new, :create]
  delete "sessions", to: "sessions#destroy", as: :sign_out

end

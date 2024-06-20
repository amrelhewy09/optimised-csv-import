Rails.application.routes.draw do
  resources :movies, only: [:index]
  resources :actors, only: [:index]

  root to: "movies#index"
end

Rails.application.routes.draw do
  resources :tasks, only: %i[index create show edit update destroy] do
    patch :toggle, on: :member
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  root "tasks#index"
end

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :games, only: :create
  resources :game_participants, only: :update
  resources :admin_token, only: :create
end

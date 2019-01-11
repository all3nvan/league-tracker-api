Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'single_page_app_initializations', to: 'single_page_app_initializations#all_normalized_data'
  resources :games, only: :create
  resources :game_participants, only: :update
  resources :admin_token, only: :create
  resources :auth_checks, only: :index
  resources :ratings, only: :index
  resources :team_combinations, only: :create
end

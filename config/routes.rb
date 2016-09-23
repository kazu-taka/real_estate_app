Rails.application.routes.draw do
  devise_for :users
  resources :houses
  resources :comments, only: [:create, :destroy]
  root 'houses#index'
end

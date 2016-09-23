Rails.application.routes.draw do
  devise_for :users
  resources :houses
  root 'houses#index'
end

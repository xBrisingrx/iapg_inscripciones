Rails.application.routes.draw do
  get 'registrarse', to: 'inscriptions#new', as: 'registrarse'
  get 'te_esperamos/:id', to: 'inscriptions#show', as: 'te_esperamos'

  resources :inscriptions do
    get 'credential'
  end
  root 'inscriptions#index'
  get 'main/index'
  namespace :authentication, path: '', as: '' do
    resources :users, only: [:index,:new, :create, :edit, :update]
      post 'disable_user', to: 'users#disable', as: 'disable_user'
    resources :sessions, only: [:create]
    get 'login', to: 'sessions#new', as: 'login'
    get 'logout', to: 'sessions#destroy', as: 'logout'
  end
end

Rails.application.routes.draw do
  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  get 'registrarse', to: 'inscriptions#registrarse', as: 'registrarse'
  get 'te_esperamos/:id', to: 'inscriptions#show', as: 'te_esperamos'

  resources :inscriptions do
    get 'credential'
    post 'disable', on: :collection
    get 'inscription_list', on: :collection
    get 'pdf_inscripcion/:inscription_id', to: 'inscriptions#pdf_inscription', as: 'pdf_inscripcion'
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

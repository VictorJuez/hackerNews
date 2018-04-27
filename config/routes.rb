Rails.application.routes.draw do
  get 'sessions/create'

  get 'sessions/destroy'

  resources :submissions
  resources :users
  
  get 'newest' => 'submissions#newest'
  get 'ask' => 'submissions#ask'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  post 'submissions/:id/vote' => 'submissions#vote'
  post 'submissions/:id/unvote' => 'submissions#unvote'
  
  resources :sessions, only: [:create, :destroy]

  
  root :to => "submissions#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end

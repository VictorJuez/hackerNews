Rails.application.routes.draw do
  resources :replies
  get 'sessions/create'

  get 'sessions/destroy'

  resources :submissions
  resources :users
  resources :comments

  
  get 'newest' => 'submissions#newest'
  get 'ask' => 'submissions#ask'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'threads' => 'comments#threads'

  post 'submissions/:id/vote' => 'submissions#vote'
  post 'submissions/:id/unvote' => 'submissions#unvote'
  post 'comments/:id/vote' => 'comments#vote'
  post 'comments/:id/unvote' => 'comments#unvote'

  get 'comments/:id/new_reply' => 'comments#new_reply'
  
  resources :sessions, only: [:create, :destroy]

  
  root :to => "submissions#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end

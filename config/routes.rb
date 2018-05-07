Rails.application.routes.draw do
  get 'sessions/create'

  get 'sessions/destroy'

  resources :submissions
  resources :users
  resources :comments
  resources :replies

  
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
  post 'replies/:id/vote' => 'replies#vote'
  post 'replies/:id/unvote' => 'replies#unvote'
  post 'repliesR' => 'replies#create_reply'

  get 'comments/:id/new_reply' => 'comments#new_reply'
  get 'replies/:id/new_reply' => 'replies#new_reply'
  get '/submissions/:id/comments' => 'comments#submission_comments'
  get '/comments/:id/replies' => 'replies#comment_replies'
    
  resources :sessions, only: [:create, :destroy]

  
  root :to => "submissions#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end

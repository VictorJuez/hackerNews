Rails.application.routes.draw do

#API
  namespace 'api' do
    namespace 'v1' do

      #submissions
      get '/submissions' => 'submissions#index'
      get '/submissions/newest' => 'submissions#newest'
      get '/submissions/ask' => 'submissions#ask'
      get '/submissions/new' => 'submissions#new'
      get '/submissions/:id/' => 'submissions#show'
      post '/submissions' => 'submissions#create'
      post '/submissions/:id/vote' => 'submissions#vote'
      post '/submissions/:id/unvote' => 'submissions#unvote'

      #comments
      get 'threads' => 'comments#threads'
      get '/submissions/:id/comments' => 'comments#submission_comments'
      post 'comments/:id/vote' => 'comments#vote'
      post 'comments/:id/unvote' => 'comments#unvote'
      put '/comments/:id/update' => 'comments#update'
    end
  end


  #NO API
  resources :submissions
  resources :users
  resources :comments
  resources :replies

  #sessions
  resources :sessions, only: [:create, :destroy]
  get 'sessions/create'
  get 'sessions/destroy'
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  
  #submissions
  get '/submissions' => 'submissions#index'
  get '/submissions/newest' => 'submissions#newest'
  get '/submissions/ask' => 'submissions#ask'
  get '/submissions/new' => 'submissions#new'
  get '/submissions/:id/' => 'submissions#show'
  post '/submissions' => 'submissions#create'
  post '/submissions/:id/vote' => 'submissions#vote'
  post '/submissions/:id/unvote' => 'submissions#unvote'

  #comments
  get 'threads' => 'comments#threads'
  get '/submissions/:id/comments' => 'comments#submission_comments'
  post 'comments/:id/vote' => 'comments#vote'
  post 'comments/:id/unvote' => 'comments#unvote'

  #replies
  post 'replies/:id/vote' => 'replies#vote'
  post 'replies/:id/unvote' => 'replies#unvote'
  get 'comments/:id/new_reply' => 'comments#new_reply'
  get '/comments/:id/replies' => 'replies#comment_replies'
  
  root :to => "submissions#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end

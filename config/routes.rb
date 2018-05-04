Rails.application.routes.draw do

#API
  namespace 'api' do
    namespace 'v1' do
      get '/submissions' => 'submissions#index'
      get '/submissions/newest' => 'submissions#newest'
      get '/submissions/ask' => 'submissions#ask'
      get '/submissions/new' => 'submissions#new'
      get '/submissions/:id/' => 'submissions#show'
      post '/submissions' => 'submissions#create'
    end
  end


#NO API
  resources :users
  resources :comments
  resources :replies

  #sessions
  resources :sessions, only: [:create, :destroy]
  get 'sessions/create'
  get 'sessions/destroy'

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
  #replies
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'threads' => 'comments#threads'

  
  post 'comments/:id/vote' => 'comments#vote'
  post 'comments/:id/unvote' => 'comments#unvote'
  post 'replies/:id/vote' => 'replies#vote'
  post 'replies/:id/unvote' => 'replies#unvote'

  get 'comments/:id/new_reply' => 'comments#new_reply'

  get '/submissions/:id/comments' => 'comments#submission_comments'
  get '/comments/:id/replies' => 'replies#comment_replies'
  
  root :to => "submissions#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


end

Rails.application.routes.draw do
  resources :submissions
  resources :users
  root "submissions#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

get 'newest' => 'submissions#newest'

end

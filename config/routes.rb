Rails.application.routes.draw do
  resources :session
  namespace :v1, :defaults => {:format => :json} do
    resources :users
    get 'cards/:registration_type', to: 'cards#show'
    put 'cards/:id', to: 'cards#update'
  end
end

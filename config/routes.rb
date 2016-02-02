Rails.application.routes.draw do
  resources :session
  namespace :v1, :defaults => {:format => :json} do
    get 'users', to: 'users#index'
    post 'users', to: 'users#create'
    get 'users/:id/statistics', to: 'users#statistics'
    get 'cards', to: 'cards#index'
    get 'cards/:registration_type', to: 'cards#show'
    put 'cards/:id', to: 'cards#update'
  end
end

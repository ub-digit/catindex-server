Rails.application.routes.draw do
  resources :session
  namespace :v1, :defaults => {:format => :json} do
    resources :users
    get 'cards', to: 'cards#show'
  end
end

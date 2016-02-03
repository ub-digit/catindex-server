Rails.application.routes.draw do
  resources :session
  namespace :v1, :defaults => {:format => :json} do
    get 'users', to: 'users#index'
    post 'users', to: 'users#create'
    get 'users/:id/statistics', to: 'users#statistics'
    get 'cards', to: 'cards#index'
    #get 'cards/:image_id', to: 'cards#show_by_id'
    #get 'cards/:image_id' => 'cards#show_by_id', :constraints => { :id => /[0-9]+/ }
    #get 'users/:xkonto' => 'users#show_by_xkonto', :constraints => { :xkonto => /[A-Za-z]+/ }
    get 'cards/:identifier', to: 'cards#show'
    put 'cards/:id', to: 'cards#update'
  end
end

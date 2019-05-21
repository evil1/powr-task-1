Rails.application.routes.draw do
  root('index#index')
  get 'login', to: 'index#login'
  get 'logout', to: 'index#logout'
  get 'oauth', to: 'index#callback'
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

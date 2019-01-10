Rails.application.routes.draw do
  get 'customers/map'
  get 'customers/load'
  get 'customers/fix'
  resources :customers
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'customers#map'
end

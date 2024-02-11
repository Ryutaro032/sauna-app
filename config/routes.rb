Rails.application.routes.draw do
  root 'facility#home'
  get 'facility/index', to: 'facility#index'
  
  resources :facilities
end

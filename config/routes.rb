Rails.application.routes.draw do
  root 'facility#home'
  get 'facility/index'
  
  resources :facilities
end

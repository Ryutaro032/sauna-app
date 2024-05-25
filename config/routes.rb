Rails.application.routes.draw do
  devise_for :users, :controllers => {
    :registrations => 'users/registrations'
   }
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
    get 'users/guest_sign_in', to: 'users/sessions#guest_sign_in'
  end

  root 'facilities#home'
  get 'facilities/index'

  resources :facilities do
    post 'favorites', to: 'favorites#create', on: :collection
    delete 'favorites', to: 'favorites#destroy', on: :collection
  end

  resources :users, only: [:show, :edit, :update]
  resources :posts, only: [:new, :create, :destroy]
end

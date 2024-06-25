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

  resources :facilities, only: [:show, :edit, :update] do
    member do
      post 'favorite', to: 'favorites#create'
      delete 'favorite', to: 'favorites#destroy'
    end
  end

  resources :users, only: [:show, :edit, :update]

  resources :favorites, only: [:create, :destroy]
  
  resources :posts, only: [:new, :create, :destroy] do
    resource :review_like, only: [:create, :destroy]
  end
end

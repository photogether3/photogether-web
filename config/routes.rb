Rails.application.routes.draw do
  root "landing#index"

  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: [ :new, :create ] do
    get :check_email, on: :collection
  end

  namespace :api do
    namespace :v1 do
      # auth group
      post "auth/login", to: "auth#login"
      post "auth/register", to: "auth#register"
      post "auth/otp/generate", to: "auth#generate_otp"
      post "auth/otp/verify", to: "auth#verify_otp"
      post "auth/refresh", to: "auth#refresh"
      delete "auth/logout", to: "auth#logout"

      # user group
      get "users/emails/:email/duplicated", to: "user#is_email_taken", constraints: { email: /[^\/]+/ }
      get "users/me", to: "user#show"
      put "users/me", to: "user#update"
      patch "users/password", to: "user#update_password_by_otp"
      patch "users/me/password", to: "user#update_password"
      delete "users/me/reset", to: "user#reset_data"
      delete "users/me/withdraw", to: "user#destroy"

      # category group
      get "categories", to: "category#index"
      get "categories/with-favorite-status", to: "category#index_with_favorites"

      # favorite group
      get "favorites", to: "favorite#index"
      put "favorites", to: "favorite#creates_or_updates"

      # collection group
      get "collections", to: "collection#index"
      get "collections/:id", to: "collection#show"
      post "collections", to: "collection#create"
      put "collections/:id", to: "collection#update"
      delete "collections/:id", to: "collection#destroy"

      # post group
      get "posts", to: "post#index"
      get "posts/:id", to: "post#show"
      post "posts", to: "post#create"
      put "posts/:id", to: "post#update"
      patch "posts/move", to: "post#change_collection"
      delete "posts", to: "post#destroys"
    end
  end
end

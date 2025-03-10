Rails.application.routes.draw do
  root "landing#index"

  mount Scalar::UI, at: "/docs"

  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: [ :new, :create ] do
    get :check_email, on: :collection
    get "otp", to: "users#otp", as: :otp
    post "verify-otp", to: "users#verify_otp", as: :verify_otp
  end

  resources :posts
  resources :collections

  namespace :api do
    namespace :v1 do
      # auth group
      post "auth/login", to: "auth_api#login"
      post "auth/register", to: "auth_api#register"
      post "auth/otp/generate", to: "auth_api#generate_otp"
      post "auth/otp/verify", to: "auth_api#verify_otp"
      post "auth/refresh", to: "auth_api#refresh"
      delete "auth/logout", to: "auth_api#logout"

      # user group
      get "users/emails/:email/duplicated", to: "user_api#is_email_taken", constraints: { email: /[^\/]+/ }
      get "users/me", to: "user_api#show"
      put "users/me", to: "user_api#update"
      patch "users/password", to: "user_api#update_password_by_otp"
      patch "users/me/password", to: "user_api#update_password"
      delete "users/me/reset", to: "user_api#reset_data"
      delete "users/me/withdraw", to: "user_api#destroy"

      # category group
      get "categories", to: "category_api#index"
      get "categories/with-favorite-status", to: "category_api#index_with_favorites"

      # favorite group
      get "favorites", to: "favorite_api#index"
      put "favorites", to: "favorite_api#creates_or_updates"

      # collection group
      get "collections", to: "collection_api#index"
      get "collections/:id", to: "collection_api#show"
      post "collections", to: "collection_api#create"
      put "collections/:id", to: "collection_api#update"
      delete "collections/:id", to: "collection_api#destroy"

      # post group
      get "posts", to: "post_api#index"
      get "posts/:id", to: "post_api#show"
      post "posts", to: "post_api#create"
      put "posts/:id", to: "post_api#update"
      patch "posts/move", to: "post_api#change_collection"
      delete "posts", to: "post_api#destroys"
    end
  end
end

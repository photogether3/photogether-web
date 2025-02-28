Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"
      post "auth/register", to: "auth#register"
      post "auth/otp/generate", to: "auth#generate_otp"
      post "auth/otp/verify", to: "auth#verify_otp"
      post "auth/refresh", to: "auth#refresh"
      delete "auth/logout", to: "auth#logout"
    end
  end
end

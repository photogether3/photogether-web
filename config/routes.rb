Rails.application.routes.draw do
  # 메인 페이지 라우트 설정
  root "pages/home#index"

  # 접근 거부 페이지
  get "access-denied", to: "pages/access#denied", as: :access_denied

  # 인증 관련 페이지
  namespace :session, module: "pages" do
    get "login", to: "session#index"
    post "login", to: "session#login"
    delete "logout", to: "session#logout"
  end

  # 인증된 회원 페이지
  namespace :users, module: "pages" do
    get "me", to: "users#show", as: :users_me
  end

  # 정책 라우트 설정
  namespace :policies, module: "pages" do
    get "data-deletion", to: "policies#data_deletion"
    get ":kind", to: "policies#show", as: :policy
    get ":kind/:version", to: "policies#show", as: :policy_version
  end

  # 관리자 페이지 라우트 설정
  namespace :admin, module: "pages" do
    # 대시보드
    root to: "admin/dashboard#index"

    # 회원관리
    get "users", to: "admin/users#index"
    get "users/:id", to: "admin/users#show"

    # 카테고리관리
    get "categories", to: "admin/categories#index"
    get "categories/new", to: "admin/categories#new"
    get "categories/:id/edit", to: "admin/categories#edit"
    put "categories/:id", to: "admin/categories#update"
    post "categories", to: "admin/categories#create"
    delete "categories/:id", to: "admin/categories#destroy"

    # 약관관리
    get "policies", to: "admin/policies#index"
    get "policies/new", to: "admin/policies#new"
    post "policies", to: "admin/policies#create"
    get "policies/:id", to: "admin/policies#show"
    get "policies/:id/edit", to: "admin/policies#edit"
    put "policies/:id", to: "admin/policies#update"
    delete "policies/:id", to: "admin/policies#destroy"

    # Ip 화이트리스트
    get "ip-whitelist", to: "admin/ip_whitelist#index"
    get "ip-whitelist/new", to: "admin/ip_whitelist#new"
    post "ip-whitelist", to: "admin/ip_whitelist#create"
    delete "ip-whitelist/:id", to: "admin/ip_whitelist#destroy"

    mount Scalar::UI, at: "/docs"
  end

  # API 라우트 설정
  namespace :api do
    namespace :v1 do
      # policy group
      get "policies", to: "policy_api#index"
      get "policies/:id", to: "policy_api#show"

      # auth group
      post "auth/login", to: "auth_api#login"
      post "auth/register", to: "auth_api#register"
      post "auth/otp/generate", to: "auth_api#generate_otp"
      post "auth/otp/verify", to: "auth_api#verify_otp"
      post "auth/otp/verify-and-login", to: "auth_api#verify_otp_with_generate_token"
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

      # vision group
      post "images/preview", to: "image_api#preview"
    end
  end
end

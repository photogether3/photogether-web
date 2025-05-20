Rails.application.routes.draw do
  # 메인 페이지 라우트 설정
  root "pages/home#index"

  # 정책 라우트 설정
  get "policies/data-deletion", to: "pages/policies#data_deletion"
  get "policies/:kind", to: "pages/policies#show", as: :policy
  get "policies/:kind/:version", to: "pages/policies#show", as: :policy_version
end

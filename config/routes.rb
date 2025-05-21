Rails.application.routes.draw do
  # 메인 페이지 라우트 설정
  root "pages/home#index"

  # 정책 라우트 설정
  scope "policies" do
    get "data-deletion", to: "pages/policies#data_deletion"
    get ":kind", to: "pages/policies#show", as: :policy
    get ":kind/:version", to: "pages/policies#show", as: :policy_version
  end
end

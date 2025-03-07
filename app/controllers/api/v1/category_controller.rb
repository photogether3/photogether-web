class Api::V1::CategoryController < Api::ApplicationApiController
  before_action :authenticate_user!, only: [ :index_with_favorites ]

  def index
    categories = Category.order(:id)
    render json: categories, status: :ok
  end

  def index_with_favorites
    # favorite_users를 미리 로드하여 N+1 문제를 방지
    categories = Category.includes(:favorite_users).order(:id)

    # 현재 사용자가 즐겨찾기한 카테고리의 ID 목록
    favorite_category_ids = @current_user.favorite_categories.pluck(:id)

    results = categories.map do |category|
      {
        id: category.id,
        name: category.name,
        # 현재 사용자가 즐겨찾기했으면 true, 아니면 false
        is_favorite: favorite_category_ids.include?(category.id)
      }
    end

    render json: results, status: :ok
  end
end

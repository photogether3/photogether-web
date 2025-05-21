class Api::V1::FavoriteApiController < ApiController
  before_action :authenticate_user!

  def index
    render json: @current_user.favorite_categories, status: :ok
  end

  def creates_or_updates
    category_ids = params[:categoryIds]
    if category_ids.nil? || category_ids.empty?
      raise CustomError, "카테고리를 하나 이상 선택해주세요."
    end

    # 유효한 카테고리 ID만 필터링
    valid_category_ids = Category.where(id: category_ids).pluck(:id)
    if valid_category_ids.empty?
      raise CustomError, "유효한 카테고리가 없습니다. 올바른 카테고리를 선택해주세요."
    end

    puts "valid_category_ids: #{valid_category_ids}"

    # 트랜잭션으로 즐겨찾기 업데이트
    u = @current_user
    u.transaction do
      # 기존 즐겨찾기 삭제
      u.favorites.destroy_all if u.favorites.exists?

      # 새 즐겨찾기 생성
      valid_category_ids.each do |cat_id|
        u.favorites.create!(category_id: cat_id)
      end
    end

    # 업데이트 후 최신 즐겨찾기 목록을 반환
    u.favorite_categories.reload

    render json: u.favorite_categories, status: :ok
  end
end

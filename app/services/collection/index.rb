class Collection::Index
  include PaginationConcern
  include Rails.application.routes.url_helpers

  def initialize(user_id, params = {})
    @user_id = user_id

    @page = params[:page] || 1
    @per_page = params[:perPage] || 10
    @sort_order = params[:sortOrder] || "desc"
    @sort_by = params[:sortBy] || "created_at"

    # 정렬 방향 유효성 검사 추가
    @sort_order = "desc" unless [ "asc", "desc" ].include?(@sort_order.to_s.downcase)

    # 정렬 필드 유효성 검사 추가
    valid_sort_fields = [ "created_at", "updated_at", "title" ]
    @sort_by = "created_at" unless valid_sort_fields.include?(@sort_by.to_s.downcase)
  end

  def call
    # 컬렉션 조회
    collections = Collection
      .where(user_id: @user_id)
      .order(@sort_by => @sort_order)
      .includes(:category, posts: [ :image_attachment ])
      .with_posts_count
      .page(@page).per(@per_page)

    # 페이지네이션 데이터 구조 생성 - PaginationConcern의 메서드 활용
    response_data = paginated_response_for(collections) do |collection|
      collection.to_detail
    end

    # 성공 결과 반환
    Result.success(response_data)
  end
end

class Collection::Index
  include PaginationConcern
  include Rails.application.routes.url_helpers

  def initialize(user_id, params = {})
    @user_id = user_id
    @keyword = params[:keyword] # 검색 키워드 추가
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
    # 기본 쿼리: 사용자의 모든 컬렉션 조회
    base_query = Collection.where(user_id: @user_id)
    
    # 키워드가 있는 경우 처리
    if @keyword.present?
      # 시스템 컬렉션 먼저 찾기
      system_collections = base_query.where(type: ["TRASH", "UNCATEGORIZED"])
      
      # 일반 컬렉션 중에서 키워드로 필터링
      user_collections = base_query
        .where.not(type: ["TRASH", "UNCATEGORIZED"])
        .where("title LIKE ?", "%#{@keyword}%")
      
      # 시스템 컬렉션과 필터링된 일반 컬렉션을 합침
      collections = system_collections.or(user_collections)
    else
      # 키워드가 없으면 모든 컬렉션 조회
      collections = base_query
    end
    
    # 정렬, 관계 로딩 등 적용
    collections = collections
      .order(@sort_by => @sort_order)
      .includes(:category, posts: [ :image_attachment ])
      .with_posts_count
      .page(@page).per(@per_page)

    # 페이지네이션 데이터 구조 생성
    response_data = paginated_response_for(collections) do |collection|
      collection.to_detail
    end

    # 성공 결과 반환
    Result.success(response_data)
  end
end
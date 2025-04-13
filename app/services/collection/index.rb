class Collection::Index
  include PaginationConcern
  include Rails.application.routes.url_helpers

  def initialize(user_id, params = {})
    @user_id = user_id
    @params = params
  end

  def call
    # 페이지네이션 파라미터 추출
    pagination = pagination_params
    puts "pagination: #{pagination.inspect}"

    # 컬렉션 조회
    collections = Collection
      .where(user_id: @user_id)
      .order(pagination[:sort_by] => pagination[:sort_order])
      .includes(:category, posts: [ :image_attachment ])
      .with_posts_count
      .page(pagination[:page]).per(pagination[:per_page])

    # 페이지네이션 데이터 구조 생성 - PaginationConcern의 메서드 활용
    response_data = paginated_response_for(collections) do |collection|
      add_image_urls_to_collection(collection)
    end

    # 성공 결과 반환
    Result.success(response_data)
  end

  private

  # pagination_concern.rb의 메서드에서 사용하는 params를 @params로 접근할 수 있도록
  def params
    @params
  end

  # 컬렉션에 이미지 URL 추가
  def add_image_urls_to_collection(collection)
    # 기본 컬렉션 정보 가져오기
    collection_data = collection.to_detail

    # 최근 이미지 3개 가져오기 (게시물 ID 내림차순)
    # ActiveStorage 관계를 사용하여 이미지가 있는 게시물만 필터링
    recent_posts_with_images = collection.posts
      .joins("INNER JOIN active_storage_attachments ON active_storage_attachments.record_id = posts.id AND active_storage_attachments.record_type = 'Post' AND active_storage_attachments.name = 'image'")
      .distinct
      .order(id: :desc)
      .limit(3)

    # 각 이미지의 원본 및 변형 URL 생성
    image_urls = recent_posts_with_images.map do |post|
      # joins로 이미 필터링되었기 때문에 attached? 체크는 불필요하지만, 안전을 위해 유지
      next unless post.image.attached?

      variants = post.image_variants

      {
        id: post.id,
        blur: variants[:blur] ? url_for(variants[:blur]) : nil,
        grid: variants[:grid] ? url_for(variants[:grid]) : nil,
        detail: variants[:detail] ? url_for(variants[:detail]) : nil
      }
    end.compact

    # 컬렉션 데이터와 이미지 정보 결합
    collection_data.merge({
      image_urls: image_urls
    })
  end
end

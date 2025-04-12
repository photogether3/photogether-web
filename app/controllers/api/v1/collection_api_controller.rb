class Api::V1::CollectionApiController < Api::ApplicationApiController
  include Api::PaginationRenderer

  before_action :authenticate_user!

  def index
    pagination = pagination_params

    collections = Collection
      .where(user_id: @current_user.id)
      .order(pagination[:sort_by] => pagination[:sort_order])
      .includes(:category, posts: [ :image_attachment ])
      .with_posts_count
      .page(pagination[:page]).per(pagination[:per_page])

    # 페이지네이션 데이터 구조 생성 후 직접 렌더링
    response_data = paginated_response_for(collections) { |collection| collection_with_image_urls(collection) }
    render json: response_data, status: :ok
  end

  def show
    collection = get_collection_or_fail
    render json: collection.to_detail, status: :ok
  end

  def create
    result = Collection::Create.new(@current_user.id, params).call
    render_result(result)
  end

  def update
    result = Collection::Update.new(@current_user.id, params[:id], params).call

    if result.success? && result.data[:collection].present?
      # 이미지 URL이 포함된 컬렉션 데이터로 교체
      result.data[:collection] = result.data[:collection].to_detail
    end

    render_result(result)
  end

  def destroy
    result = Collection::Destroy.new(@current_user.id, params[:id]).call
    render_result(result)
  end

  private

    # 카테고리를 조회하고 없으면 예외를 발생시킵니다.
    def get_category_or_fail
      category = Category.find_by(id: params[:categoryId])
      raise ActiveRecord::RecordNotFound, "카테고리를 찾을 수 없습니다." unless category
      category
    end

    # 사진첩을 조회하고 없으면 예외를 발생시킵니다.
    def get_collection_or_fail
      collection = Collection
        .where(id: params[:id], user_id: @current_user.id)
        .includes(:category, posts: [ :image_attachment ])
        .first
      raise ActiveRecord::RecordNotFound, "사진첩을 찾을 수 없습니다." unless collection
      collection
    end

    # 사진첩 데이터에 이미지 URL과 변형 URL 추가
    def collection_with_image_urls(collection)
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
          grid: variants[:grid] ? url_for(variants[:grid]) : nil
        }
      end.compact

      # 컬렉션 데이터와 이미지 정보 결합
      collection_data.merge({
        image_urls: image_urls
      })
    end
end

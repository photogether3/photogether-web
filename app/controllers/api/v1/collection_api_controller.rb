class Api::V1::CollectionApiController < Api::ApplicationApiController
  before_action :authenticate_user!
  before_action :get_category_or_fail, only: [ :create, :update ]
  before_action :get_collection_or_fail, only: [ :show, :update, :destroy ]

  def index
    # 기본값 설정
    page       = params[:page] ||= 1
    per_page   = params[:perPage] ||= 10
    sort_order = params[:sortOrder] ||= "desc"
    sort_by    = params[:sortBy] ||= "created_at"

    # 사진첩 목록 조회
    collections = Collection
      .where(user_id: @current_user.id)
      .order(sort_by => sort_order)
      .includes(:category, posts: [ :image_attachment ])
      .with_posts_count
      .page(page).per(per_page)

    # JSON 변환
    render json: {
      per_page: collections.limit_value,
      total_item_count: collections.total_count,
      total_page_count: collections.total_pages,
      current_page: collections.current_page,
      items: collections.map { |collection|
        collection.to_detail.merge(
          image_urls: collection.posts.order(id: :desc).limit(3).map { |post|
            post.image.attached? ? url_for(post.image) : nil
          }.compact
        )
      }
    }, status: :ok
  end

  def show
    render json: @collection.to_detail.merge(
      image_urls: @collection.posts.order(id: :desc).limit(3).map { |post|
        post.image.attached? ? url_for(post.image) : nil
      }.compact
    ), status: :ok
  end

  def create
    Collection.create!(
      title: params[:title],
      category_id: @category.id,
      user_id: @current_user.id,
      type: "DEFAULT"
    )

    render json: { message: "사진첩이 생성되었어요." }, status: :ok
  end

  def update
    raise CustomError, "수정할 수 없는 사진첩입니다." if @collection.type != "DEFAULT"

    @collection.update!(
      title: params[:title],
      category_id: @category.id
    )

    render json: { message: "사진첩이 업데이트되었어요." }, status: :ok
  end

  def destroy
    # 게시물을 가지고 있는 사진첩은 삭제 이전에
    # 사용자의 휴지통 사진첩으로 게시물을 이동시키는 작업이 필요
    @collection.destroy

    render json: { message: "사진첩이 삭제되었어요." }, status: :ok
  end

  private

  # 카테고리를 조회하고 없으면 예외를 발생시킵니다.
  def get_category_or_fail
    @category = Category.find_by(id: params[:categoryId])
    raise ActiveRecord::RecordNotFound, "카테고리를 찾을 수 없습니다." unless @category
  end

  # 사진첩을 조회하고 없으면 예외를 발생시킵니다.
  def get_collection_or_fail
    @collection = Collection
      .where(id: params[:id], user_id: @current_user.id)
      .includes(:category, posts: [ :image_attachment ])
      .first
    puts @collection.as_json
    raise ActiveRecord::RecordNotFound, "사진첩을 찾을 수 없습니다." unless @collection
  end
end

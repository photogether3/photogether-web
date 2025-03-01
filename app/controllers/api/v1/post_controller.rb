class Api::V1::PostController < Api::ApplicationApiController
  before_action :authenticate_user!
  before_action :get_collection_or_fail, only: [ :index, :create ]
  before_action :get_post_or_fail, only: [ :show, :update, :destroy ]

  def index
    # 기본값 설정
    page       = params[:page] ||= 1
    per_page   = params[:perPage] ||= 10
    sort_order = params[:sortOrder] ||= "desc"
    sort_by    = params[:sortBy] ||= "created_at"

    # 게시물 조회
    posts = Post.where(user_id: @current_user.id, collection_id: @collection.id)
                .order(sort_by => sort_order)
                .includes(:collection, :post_metadata)
                .page(page).per(per_page)

    # JSON 변환
    render json: {
      per_page: posts.limit_value,
      total_item_count: posts.total_count,
      total_page_count: posts.total_pages,
      current_page: posts.current_page,
      items: posts.map { |post| post.to_detail.merge(
        image_url: url_for(post.image)
      ) }
    }, status: :ok
  end

  def show
    render json: @post.to_detail.merge(
      image_url: url_for(@post.image)
    ), status: :ok
  end

  def create
    title         = params[:title]
    content       = params[:content]
    file          = params[:file]
    metadata_list = JSON.parse(params[:metadataStringify] || "[]")

    raise CustomError, "파일은 필수값 입니다." if file.blank?

    post = Post.create_usecase(@current_user.id, @collection.id, title, content, metadata_list, file)

    image_url = post.image.attached? ? url_for(post.image) : nil
    render json: post.as_json.merge(image_url: image_url), status: :ok
  end

  def update
    puts "Post update"
  end

  def change_collection
    puts "Post change collection"
  end

  def destroys
    puts "Post destroys"
  end

  private

  # 사진첩을 조회하고 없으면 예외를 발생시킵니다.
  def get_collection_or_fail
    @collection = Collection.find_by(id: params[:collectionId], user_id: @current_user.id)
    raise ActiveRecord::RecordNotFound, "사진첩을 찾을 수 없습니다." unless @collection
  end

  # 게시물을 조회하고 없으면 예외를 발생시킵니다.
  def get_post_or_fail
    @post = Post.find_by(id: params[:id], user_id: @current_user.id)
    raise ActiveRecord::RecordNotFound, "게시물을 찾을 수 없습니다." unless @post
  end
end

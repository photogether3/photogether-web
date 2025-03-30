class Api::V1::PostApiController < Api::ApplicationApiController
  before_action :authenticate_user!
  before_action :pre_set_create_or_update_params, only: [ :create, :update ]
  before_action :get_collection_or_fail, only: [ :index, :create, :change_collection ]
  before_action :get_post_or_fail, only: [ :show, :update ]
  before_action :get_post_group, only: [ :change_collection, :destroys ]

  def index
    # 기본값 설정
    page       = params[:page] ||= 1
    per_page   = 12
    sort_order = params[:order] ||= "desc"
    sort_by    = params[:order_by] ||= "created_at"
    keyword    = params[:keyword] ||= ""
    filter_by  = params[:filter_by] ||= ""

    # 게시물 조회 기본 쿼리
    @posts = Post.includes(:user, :post_metadata, collection: :category, image_attachment: :blob)

    # 검색어 필터링
    @posts = @posts.where("posts.title LIKE :q OR posts.content LIKE :q", q: "%#{keyword}%") if keyword.present?

    # 카테고리 필터링
    if filter_by.present?
      @posts = @posts.joins(collection: :category).where(collections: { category_id: filter_by })
    end

    # 정렬 - 유효성 검사
    valid_sort_fields = %w[created_at updated_at title]
    sort_by = "created_at" unless valid_sort_fields.include?(sort_by)

    # 정렬 및 페이징 적용
    @posts = @posts.order(sort_by => sort_order).page(page).per(per_page)

    # 카테고리 목록 (필터용)
    @categories = Category.all.order(:name)

    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    render json: @post.to_detail.merge(
      image_url: url_for(@post.image)
    ), status: :ok
  end

  def create
    file          = params[:file]
    metadata_list = JSON.parse(params[:metadataStringify] || "[]")
    raise CustomError, "파일은 필수값 입니다." if file.blank?

    Post.create_usecase(@current_user.id, @collection.id, @title, @content, metadata_list, file)
    render json: { message: "게시물이 생성되었습니다." }, status: :ok
  end

  def update
    metadata_list = params[:metadataList] || []
    @post.update_usecase(@title, @content, metadata_list)
    render json: { message: "게시물이 수정되었습니다." }, status: :ok
  end

  def change_collection
    @posts.update_all(collection_id: @collection.id)
    render json: { message: "게시물이 이동되었습니다." }, status: :ok
  end

  def destroys
    # 현재 사용자의 휴지통 컬렉션 찾기
    trash_collection = Collection.find_by(user_id: @current_user.id, type: "TRASH")

    if trash_collection.nil?
      # 휴지통이 없으면 생성
      trash_collection = Collection.create!(
        user_id: @current_user.id,
        type: "TRASH",
        title: "휴지통",
        category_id: nil
      )
    end

    # 게시물의 컬렉션 ID를 휴지통 컬렉션 ID로 변경
    @posts.update_all(collection_id: trash_collection.id)

    render json: { message: "게시물이 휴지통으로 이동되었습니다." }, status: :ok
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
    puts @post.as_json
    raise ActiveRecord::RecordNotFound, "게시물을 찾을 수 없습니다." unless @post
  end

  # 게시물 그룹을 조회합니다.
  def get_post_group
    post_ids = params[:postIds] || []
    @posts = Post.where(id: post_ids) || []
    raise ActiveRecord::RecordNotFound, "게시물 그룹을 찾을 수 없습니다." if @posts.empty?
  end

  # 게시물 생성 또는 수정 시 필요한 파라미터를 미리 설정합니다.
  def pre_set_create_or_update_params
    @title         = params[:title]
    @content       = params[:content]
  end
end
